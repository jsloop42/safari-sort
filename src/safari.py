from pathlib import Path
import plistlib

input_path = Path.home() / 'Library' / 'Safari' / 'Bookmarks.plist'
output_path = Path.home() / 'Library' / 'Safari' / 'Bookmarks.plist'

def order_bookmarks_by_name(bookmark_node):
    if 'Children' in bookmark_node and 'Title' in bookmark_node and bookmark_node['Title'] != 'BookmarksBar':  # ignores favourites
    # if 'Children' in bookmark_node:  # sorts all folders
        children = bookmark_node['Children']

        # separate directories and bookmarks
        directories = []
        bookmarks = []

        for child in children:
            if 'Children' in child:
                is_bookmarks_bar = False
                directories.append(child)
            else:
                is_bookmarks_bar = False
                bookmarks.append(child)

        def get_title(hm):
            if 'URIDictionary' in hm:
                return hm['URIDictionary']['title']
            return hm['Title']

        # case-insensitive sorting by name
        def sort_key(item):
            # print(get_title(item))
            return get_title(item).lower()

        # Sort directories and bookmarks
        sorted_directories = sorted(directories, key=sort_key)
        sorted_bookmarks = sorted(bookmarks, key=sort_key)

        # recursively process sorted directories and bookmarks
        sorted_directories = [order_bookmarks_by_name(dir) for dir in sorted_directories]

        sorted_children = sorted_directories + sorted_bookmarks
        bookmark_node['Children'] = sorted_children

    return bookmark_node

# Load Safari bookmarks plist
with input_path.open('rb') as fp:
    safari_bookmarks = plistlib.load(fp)

# Order the bookmarks by name
ordered_safari_bookmarks = order_bookmarks_by_name(safari_bookmarks)

# Save the ordered bookmarks to an binary plist file
with output_path.open('wb') as fp:
    plistlib.dump(ordered_safari_bookmarks, fp, fmt=plistlib.FMT_BINARY)

print("Bookmarks sorted")
