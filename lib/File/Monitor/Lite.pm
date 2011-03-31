package File::Monitor::Lite;

use 5.010000;
use strict;
use warnings;
use File::Find::Rule;
use File::Monitor;
use base 'Class::Accessor::Fast';
__PACKAGE__->mk_accessors( 
qw(
   monitor 
   watch_list
   in
   name
));
	
our $VERSION = '0.01';

sub new {
    my $class = shift;
    my $self = {@_};
    bless $self, $class;
    my %w_list = 
        map{$_ => 1}
        File::Find::Rule
            ->file()
            ->name($self->name)
            ->in($self->in);
    $self->watch_list(\%w_list);
    $self->monitor(new File::Monitor);
    $self->monitor->watch($_)for keys %w_list;
    return $self;
}

sub check {
    my $self = shift;
    my $w_list=$self->watch_list;
    my @new_file_list = File::Find::Rule
        ->file()
        ->name($self->name)
        ->in($self->in);
    my @new_files = grep { not exists $$w_list{$_} } @new_file_list;
    my @changes = $self->monitor->scan;
    my @deleted_files = 
        map{$_->name}
        grep{$_->deleted} @changes;
    my @modified_files = 
        map{$_->name}
        grep{not $_->deleted} @changes;

    # update waching list
    foreach(@new_files){
        $$w_list{$_}=1;
        $self->monitor->watch($_);
    }
    # unwatch deleted files
    foreach(@deleted_files){
        $self->monitor->unwatch($_);
        delete $$w_list{$_};
    }
    $self->watch_list($w_list);

    $self->{created}= [@new_files];
    $self->{modified}=[@modified_files];
    $self->{observed}=[ keys %$w_list];
    $self->{deleted}= [@deleted_files];

    1;
}
sub created {
    my $self = shift;
    return @{$self->{created}}
}
sub modified {
    my $self = shift;
    return @{$self->{modified}};
}
sub observed {
    my $self = shift;
    return @{$self->{observed}};
}
sub deleted {
    my $self = shift;
    return @{$self->{deleted}};
}

# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

File::Monitor::Lite - Perl extension for blah blah blah

=head1 SYNOPSIS

  use File::Monitor::Lite;
  
  my $monitor = new File::Monitor::Lite({
      dir => '.',
      name => '*.html',
  })

  while ($monitor->check() and sleep 1){
      my @deleted_files = $monitor->deleted;
      my @modified_files = $monitor->modified;
      my @created_files = $monitor->created;
      my @observing_files = $monitor->observed;
  }

=head1 DESCRIPTION

Stub documentation for File::Monitor::Lite, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

dryman, E<lt>dryman@apple.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by dryman

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
