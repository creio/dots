#!/usr/bin/env python

import os
import shutil

CLEAN_FILES = [
    #'~/hostr/',
    #'~/.bzr.log',
    #'~/.cache/babl/',
    #'~/.cache/gegl-0.2/',
    #'~/.cache/google-chrome/',
    #'~/.cache/gstreamer-1.0/',
    #'~/.cache/menu/',
    #'~/.cache/thumbnails/',
    #'~/.local/share/gegl-0.2/',
    #'~/.local/share/recently-used.xbel',
    #'~/.local/share/Trash/',
    #'~/.ncmpcpp/error.log',
    # '~/.npm/',
    # '~/.nv/',
    #'~/.pki/',
    #'~/.pylint.d/',
    #'~/.recently-used',
    #'~/.thumbnails/',
    #'~/.w3m/',
    #'~/.xsession-errors.old'
    '/home/denis/test/2/',
    '/home/denis/test/3/'
]

def answer(question, default="n"):
    prompt = "%s (y/[n]) " % question
    ans = input(prompt).strip().lower()

    if not ans:
        ans = default

    if ans == "y":
        return True
    return False


def remove_clean():
    found = []

    print("\n")
    for jfile in CLEAN_FILES:
        extra = os.path.expanduser(jfile)
        if os.path.exists(extra):
            found.append(extra)
            print("    %s" % jfile)
    total = len(found)

    if total == 0:
        print("No clean files found :)\n")
        return

    if answer("\nRemove all?", default="n"):
        list_paths = (CLEAN_FILES)
        print ('Список путей - {}'.format(list_paths))
        for path in list_paths:
            print (path)
            for the_file in os.listdir(path): # Смотрим в каждом указанном пути наличие файлов.
                file_path = os.path.join(path, the_file)
                print(file_path)
                try:
                    if os.path.isfile(file_path):
                        os.unlink(file_path)
                    elif os.path.isdir(file_path): shutil.rmtree(file_path)
                except Exception as e:
                    print(e)

        print("\nAll clean cleaned")

    else:
        print("\nNo files removed")


if __name__ == '__main__':
    remove_clean()
