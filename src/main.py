#!/usr/bin/env python

import os
import sys
import json
import argparse
import importlib
import importlib.util
import inspect


def main():
    parser = argparse.ArgumentParser(
            prog='DevopsTasks',
            description='Devops Tassk',
            epilog='Program to automate devops tasks')

    subparsers = parser.add_subparsers()

    subparsers.add_parser("build").set_defaults(func=build)
    subparsers.add_parser("pack").set_defaults(func=pack)
    subparsers.add_parser("release").set_defaults(func=release)
    subparsers.add_parser("deploy").set_defaults(func=deploy)
    copyArgs = sys.argv
    copyArgs.pop(0)
    args = parser.parse_args(copyArgs)
    args.func(args)
# end main

def readVars():
    name=""
    with open(os.path.join(os.environ["CURDIR"], 'NAME')) as f:
        name=f.read().strip()
    return {"name":name, "build":"0.0.0-build"}

def build(args:argparse.Namespace):
    m = readVars()
    with open(os.path.join(os.environ["CURDIR"], '.build'), "w") as f:
        f.write(m["build"])

    projectTasks("build", m)
# end build

def pack(args:argparse.Namespace):
    m = readVars()
    projectTasks("pack", m)
# end pack

def release(args:argparse.Namespace):
    m = readVars()
    if not os.path.isfile(os.path.join(os.environ["CURDIR"], '.build')):
        print("")
        print("Build file is missing. Run ./build.sh first")
        print("")
        exit(-1)

    major_minor = readCurDirFile("VERSION", "0.0")
    revision = int(readCurDirFile("REVISION", "0"))
    revision = revision + 1
    writeCurDirFile("REVISION", '%d'%(revision))
    version = '%s.%d'%(major_minor, revision)
    m["version"] = version
    m["major_minor"] = major_minor
    m["revision"] = revision

    projectTasks("release", m)
# end release

def deploy(args:argparse.Namespace):
    m = readVars()
    projectTasks("deploy", m)
# end deploy

def projectTasks(funcName, arg):
    curDir = os.environ["CURDIR"]
    tasksFile = os.path.join(curDir, '.tasks.py')
    mod = load_code(tasksFile, "dyn")
    if hasattr(mod, funcName):
        func = getattr(mod,funcName)
        spec = inspect.getfullargspec(func)
        if len(spec.args) > 0:
            func(arg)
        else:
            func()
    else:
        print("No %s function defined int .tasks.py"%(funcName))
# end build

def load_code(filepath, name):
    spec = importlib.util.spec_from_file_location(name, filepath)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module

def readCurDirFile(file, defval):
    v = defval
    filePath = os.path.join(os.environ["CURDIR"], file)
    if os.path.isfile(filePath):
        with open(filePath) as f:
            v = f.read().strip()
    return v

def writeCurDirFile(file, contents):
    with open(os.path.join(os.environ["CURDIR"], file), "w") as f:
        f.write(contents)


main()
