#
#  safari.pyx
#  iomarks-mac
#
#  Created by jsloop on 26/01/20.
#  Copyright © 2020 EstoApps OÜ. All rights reserved.
#

from pathlib import Path
from plistlib import load
from cython.parallel import prange

cdef class Worker:
    cdef object path
    cdef object plist
    cdef dict bookmarks

    def __cinit__(self):
        self.path = '{}{}'.format(Path.home(),
                                  '/Library/Safari/Bookmarks.plist')
        self.bookmarks = {
            'WebBookmarkUUID': '1981E7B1-C5DC-4B3D-B6EF-3A4A88AB7165',
            'WebBookmarkFileVersion': 1,
            'Sync': {},
            'Children': [{
                'WebBookmarkUUID': '9C5E29A4-3D2F-4085-8CD9-8DAFF30F166D', 
                'Children': [{
                    'WebBookmarkUUID': '7B91A0DC-5D86-42B3-A52E-D302D1BF2292',
                    'ReadingListNonSync': {
                        'neverFetchMetadata': False
                    }, 
                    'URLString': 'https://e-resident.gov.ee/welcome/',
                    'Sync': {},
                    'WebBookmarkType': 'WebBookmarkTypeLeaf',
                    'URIDictionary': {
                        'title': 'Welcome | e-Residency'
                    }
                }, {
                    'WebBookmarkUUID': 'AAC44B3E-E6F6-4272-A0FE-2E1826044DD5',
                    'ReadingListNonSync': {
                        'neverFetchMetadata': False
                    }, 
                    'URLString': 'https://www2.politsei.ee/en/teenused/inquiries/',
                    'Sync': {},
                    'WebBookmarkType': 'WebBookmarkTypeLeaf',
                    'URIDictionary': {
                        'title': 'Document validity check'
                    }
                }, {
                    'WebBookmarkUUID': 'FCB6EFD9-F98D-474F-B764-426B64E272E6',
                    'ReadingListNonSync': {
                        'neverFetchMetadata': False
                    }, 
                    'URLString': 'https://www.workinestonia.com/',
                    'Sync': {},
                    'WebBookmarkType': 'WebBookmarkTypeLeaf',
                    'URIDictionary': {
                        'title': 'Why Estonia? - Work in Estonia'
                    }
                }],
                'Sync': {},
                'WebBookmarkType': 'WebBookmarkTypeList',
                'Title': 'EstEID'
            }, {
                'WebBookmarkUUID': '3C5E29A4-3D2F-4085-8CD9-8DAFF30F1611', 
                'Children': [],
                'Sync': {},
                'WebBookmarkType': 'WebBookmarkTypeLeaf',
                'Title': 'Apple'
            }],
            'Title': '',
            'WebBookmarkType': 'WebBookmarkTypeList'
        }

    @property
    def path(self):
        return self.path

    @path.setter
    def path(self, p):
        self.path = p

    @property
    def bookmarks(self):
        return self.bookmarks

    @bookmarks.setter
    def bookmarks(self, hm):
        self.bookmarks = hm

    cpdef double evaluate(self, double x) except *:
        return x * 2

    cdef open_plist(self):
        print('opening bookmarks.plist: ', self.path)
        with open(self.path, 'rb') as fp:
            self.plist = load(fp)
        print('plist ', self.bookmarks)

    cdef getTitle(self, hm):
        if 'URIDictionary' in hm:
            return hm['URIDictionary']['title']
        return hm['Title']

    cdef orderByTitleAsc(self, hm):
        print('ordering by title ascending for node')
        if 'Children' in hm:
            print('found children', hm)
            xs = hm['Children']
            count = len(xs)
            print('children count', count)
            if count > 0:
                for x in xs:
                    print(self.getTitle(x))
                    xs = [self.orderByTitleAsc(x)
                          for x in
                          sorted(xs, key=lambda y: self.getTitle(y))]
                hm['Children'] = xs
        print('bookmarks:', hm)
        return hm

    cdef parallel_exec(self):
        print('parallel exec')
        cdef int i
        cdef int n = 30
        cdef int sum = 30
        for i in prange(n, nogil=True):
            sum += 1
        print(sum)

    cpdef void process(self):
        self.open_plist()
        # self.parallel_exec()
        self.orderByTitleAsc(self.bookmarks)


if __name__ == '__main__':
    w = Worker()
    w.process()
