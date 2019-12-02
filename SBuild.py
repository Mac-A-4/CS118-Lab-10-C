import subprocess
import os
import os.path
import sys
import fnmatch

def spawn(_process, _arguments):
    line = [_process] + _arguments
    process = subprocess.Popen(line)
    process.communicate()
    if process.wait() == 0:
        return True
    return False

def compile(_source):
    assembler = "as"
    directory, tail = os.path.split(_source)
    source_name = os.path.splitext(tail)[0]
    output = os.path.join(directory, source_name + ".o")
    arguments = ["-g", _source, "-o", output]
    return spawn(assembler, arguments), output

def link(_objects, _output):
    linker = "ld"
    arguments = ["-g"] + _objects + ["-o", _output]
    return spawn(linker, arguments), _output

def output_argument():
    if len(sys.argv) < 2:
        return None
    return os.path.join(os.getcwd(), sys.argv[1])

def input_arguments():
    if len(sys.argv) < 3:
        return None
    keys = []
    output = []
    for i in range(2, len(sys.argv)):
        keys.append(sys.argv[i])
    for _file in os.listdir(os.getcwd()):
        for _key in keys:
            if fnmatch.fnmatch(_file, _key):
                output.append(_file)
    if len(output) > 0:
        return output
    return None

__output = output_argument()
__input = input_arguments()

if __output == None:
    print("Failed to Parse Sources")
    sys.exit(1)
if __input == None:
    print("Failed to Parse Arguments")
    sys.exit(2)

__objects = []

for __source in __input:
    __status, __object = compile(__source)
    if __status == False:
        print("Failed to Compile " + __source)
        sys.exit(3)
    __objects.append(__object)

__status, __binary = link(__objects, __output)

if __status == False:
    print("Failed to Link")
    sys.exit(4)

print("Compiled and Linked Successfully")
