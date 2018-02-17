# Batch-Script-To-Compile-C-Programs

This Script Compile C++ sources.
You need the bin folder of your compiler in your path.
The output file name is main.exe.
The outpur path is bin\debug\main.exe.
The script make a object path (obj\subfolders|sources).
The script looks for the files from where it is and subfolders.
The script can make a simple built with the last modified files or a make rebuilt.
In the file CompilationFlags.options set the flags that you want to use when compiling.
In the file IncludeFiles.linker set extra libraries path you will use.
In the file LinkerFiles.linker set the libs path you will use.
In the file LinkerOptions.options set the linker options.
The file FilesLogs.log, the script use this file to add files dates to compare.
