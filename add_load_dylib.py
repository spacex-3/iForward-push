#!/usr/bin/env python3
"""
Add LC_LOAD_DYLIB command for libcurl to a Mach-O binary
This allows dyld to load libcurl.dylib at runtime even though
the binary was compiled with -undefined dynamic_lookup
"""
import struct
import sys

# Mach-O constants
MH_MAGIC_64 = 0xFEEDFACF
MH_CIGAM_64 = 0xCFFAEDFE
LC_LOAD_DYLIB = 0xC
LC_ID_DYLIB = 0xD

def add_load_dylib(filepath, dylib_path):
    with open(filepath, 'r+b') as f:
        # Read header
        magic = struct.unpack('<I', f.read(4))[0]

        if magic not in (MH_MAGIC_64, MH_CIGAM_64):
            # Try universal binary - skip to arm64 slice
            f.seek(0)
            fat_magic = struct.unpack('>I', f.read(4))[0]
            if fat_magic == 0xCAFEBABE:  # FAT_MAGIC
                nfat_arch = struct.unpack('>I', f.read(4))[0]
                for i in range(nfat_arch):
                    cputype, cpusubtype, offset, size, align = struct.unpack('>IIIII', f.read(20))
                    if cputype == 0x0100000C:  # CPU_TYPE_ARM64
                        f.seek(offset)
                        magic = struct.unpack('<I', f.read(4))[0]
                        break

        if magic not in (MH_MAGIC_64, MH_CIGAM_64):
            print(f"Not a 64-bit Mach-O file: {filepath}")
            return False

        # Read Mach-O header
        f.seek(0)
        header = f.read(32)
        magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds, flags, reserved = struct.unpack('<IIIIIIII', header)

        # Read to end of load commands
        f.seek(32)
        load_commands = f.read(sizeofcmds)
        rest_of_file = f.read()

        # Create new LC_LOAD_DYLIB command
        dylib_name = dylib_path.encode('utf-8') + b'\x00'
        # Align to 8 bytes
        while len(dylib_name) % 8 != 0:
            dylib_name += b'\x00'

        # LC_LOAD_DYLIB structure:
        # cmd (4 bytes)
        # cmdsize (4 bytes)
        # name offset (4 bytes) = 24 (size of dylib structure)
        # timestamp (4 bytes)
        # current_version (4 bytes)
        # compatibility_version (4 bytes)
        # name (variable, null-terminated, padded to 8 bytes)

        cmdsize = 24 + len(dylib_name)
        new_load_cmd = struct.pack('<IIIIII',
            LC_LOAD_DYLIB,  # cmd
            cmdsize,         # cmdsize
            24,              # name offset
            2,               # timestamp
            0x00040000,      # current_version 4.0.0
            0x00040000       # compatibility_version 4.0.0
        ) + dylib_name

        # Update header
        new_ncmds = ncmds + 1
        new_sizeofcmds = sizeofcmds + len(new_load_cmd)
        new_header = struct.unpack('<IIIIIIII', header)
        new_header = list(new_header)
        new_header[4] = new_ncmds
        new_header[5] = new_sizeofcmds
        new_header = struct.pack('<IIIIIIII', *new_header)

        # Write modified file
        f.seek(0)
        f.write(new_header)
        f.write(load_commands)
        f.write(new_load_cmd)
        f.write(rest_of_file)
        f.truncate()

    print(f"Added LC_LOAD_DYLIB for {dylib_path} to {filepath}")
    return True

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: add_load_dylib.py <binary> <dylib_path>")
        sys.exit(1)

    add_load_dylib(sys.argv[1], sys.argv[2])
