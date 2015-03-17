package Dancer2::Logger::Syslog;
# ABSTRACT: Dancer2 logger engine for Sys::Syslog
$Dancer2::Logger::Syslog::VERSION = '0.1';

use Moo;
use File::Basename 'basename';
use Sys::Syslog;

use Dancer2::Core::Types;

with 'Dancer2::Core::Role::Logger';

has 'log_open' => (
    is      => 'ro',
    isa     => Bool,
    lazy    => 1,
    builder => '_syslog_open',
);

# Set by calling function
has facility => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
);

has ident => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
);

has logopt => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
);

sub _syslog_open {
    my $self = shift;

    my $facility = $self->facility || 'USER';
    my $ident    = $self->ident 
                     || $self->app_name 
                     || $ENV{DANCER_APPDIR} 
                     || basename($0);
    my $logopt   = $self->logopt   || 'pid';

    openlog($ident, $logopt, $facility);
    1; # openlog() will have croaked if it can't connect
}

sub DESTROY { closelog() }

sub log {
    my ($self, $level, $message) = @_;

    $self->log_open;

    my $syslog_levels = {
        core    => 'debug',
        debug   => 'debug',
        warning => 'warning',
        error   => 'err',
        info    => 'info',
    };

    $level = $syslog_levels->{$level} || 'debug';
    my $fm = $self->format_message($level => $message);
    syslog($level, $fm);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dancer2::Logger::Syslog - Dancer2 logger engine for Sys::Syslog

=head1 VERSION

version 0.1

=head1 DESCRIPTION

This module implements a logger engine that send log messages to syslog,
through the Sys::Syslog module.

=head1 METHODS

=head2 log($level, $message)

Writes the log message to the file.

=head1 CONFIGURATION

The setting B<logger> should be set to C<Syslog> in order to use this logging
engine in a Dancer2 application.

The attributes in the following example configuration are supported:

  logger: "Syslog"

  engines:
    logger:
      Syslog:
        facility: "LOCAL0"
        ident: "my_app"
        logopt: "pid"

The allowed options are:

=over 4

=item facility 

Which syslog facility to use, defaults to 'USER'

=item ident 

String prepended to every log line, defaults to the configured I<appname> or,
if not defined, to the executable's basename.

=item logopt

Log options passed to C<openlog()> as per Sys::Syslog's docs. Defaults to
'pid'. 

=back

=head1 METHODS

=head1 DEPENDENCY

This module depends on L<Sys::Syslog>.

=head1 SEE ALSO

See L<Dancer2> for details about logging in route handlers.

=head1 AUTHORS

=over 4

=item *

Andy Beverley <andy@andybev.com>

=item *

Yanick Champoux <yanick@cpan.org>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Andy Beverley, Yanick Champoux,
Alexis Sukrieh

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
