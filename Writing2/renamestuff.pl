#!/usr/bin/perl
use strict;
use warnings;
use File::Find;
use File::Copy;
use threads;
use Thread::Queue;

# Base directory (or use current directory)
my $directory = shift || ".";

# Two queues: One for directories, one for files
my $dir_queue = Thread::Queue->new();
my $file_queue = Thread::Queue->new();

# Step 1: Find all files and directories
find(sub {
    if (-d) {
        $dir_queue->enqueue($File::Find::name);  # Enqueue directories first
    } elsif (-f) {
        $file_queue->enqueue($File::Find::name); # Enqueue files after
    }
}, $directory);

# Step 2: Rename directories first (prevent conflicts)
my $dir_threads = 2;  # Adjust based on CPU power
my @dir_workers;
for (1..$dir_threads) {
    push @dir_workers, threads->create(\&rename_dirs);
}
$dir_queue->end();
$_->join() for @dir_workers;

# Step 3: Rename files
my $file_threads = 4;  # More threads for file renaming
my @file_workers;
for (1..$file_threads) {
    push @file_workers, threads->create(\&rename_files);
}
$file_queue->end();
$_->join() for @file_workers;

print "Done renaming folders & files!\n";

# Rename folders function
sub rename_dirs {
    while (my $folder = $dir_queue->dequeue_nb()) {  # Non-blocking dequeue
        my ($parent, $name) = ($folder =~ m|(.+)/([^/]+)$|);
        next unless defined $parent && defined $name;

        my $new_name = $name;
        $new_name =~ s/[^a-zA-Z0-9._-]/_/g;  # Replace invalid characters

        if ($new_name ne $name) {
            my $new_path = "$parent/$new_name";
            if (-e $new_path) {
                warn "Skipping $folder -> $new_name (already exists)\n";
            } else {
                move($folder, $new_path) or warn "Failed to rename folder $folder: $!\n";
                print "Renamed Folder: $folder -> $new_name\n";
            }
        }
    }
}

# Rename files function
sub rename_files {
    while (my $file = $file_queue->dequeue_nb()) {
        my ($parent, $name) = ($file =~ m|(.+)/([^/]+)$|);
        next unless defined $parent && defined $name;

        my $new_name = $name;
        $new_name =~ s/[^a-zA-Z0-9._-]/_/g;

        if ($new_name ne $name) {
            my $new_path = "$parent/$new_name";
            if (-e $new_path) {
                warn "Skipping $file -> $new_name (already exists)\n";
            } else {
                move($file, $new_path) or warn "Failed to rename file $file: $!\n";
                print "Renamed File: $file -> $new_name\n";
            }
        }
    }
}
