package Test::Webbench::SysstatPresenter;

=head1 NAME

SysstatPresenter - Perl module to parse output files from sysstat.

=head1 SYNOPSIS

 use SysstatPresenter;

 my $parser = new SysstatPresenter;
 $parser->parse($text);

=head1 DESCRIPTION

This module transforms sysstat output into a hash that can be used to generate
XML.

=head1 FUNCTIONS

Also see L<Test::Presenter> for functions available from the base class.

=cut

use strict;
use warnings;
use CGI;
use CGI::Pretty;
use Chart::Graph::Gnuplot qw(gnuplot);
use Test::Presenter::Sar;
use Test::Webbench::Iostat;
use Test::Webbench::Vmstat;
use XML::Simple;

use fields qw(
              cmdline
              data
              datadir
              db
              format
              log
              outdir
              sample_length
              sysctl
              system
              tablespace
              xml
);

use vars qw( %FIELDS $AUTOLOAD $VERSION );
our $VERSION = '0.1';

sub format {
    my $self = shift;
    if (@_) {
        $self->{format} = shift;
    }
    return $self->{format};
}

=head2 new()

Creates a new Test::Webbench::SysstatPresenter instance.
Also calls the Test::Presenter base class' new() routine.
Takes no arguments.

=cut

sub new {
    my $class = shift;
    my $input = shift;
    my Test::Webbench::SysstatPresenter $self = fields::new($class);

    if (-f $input) {
        $self->{xml} = XMLin($input);
    } elsif (ref($input) eq 'HASH') {
        $self->{xml} = $input->{dbt2};
    } else {
        print "I don't know what to do\n";
        exit(1);
    }

    $self->{db} = undef;
    $self->{sample_length} = 60; # Seconds.
    $self->{sysctl} = undef;
    $self->{system} = {};
    #
    # Hash of devices to plot for iostat per tablespace.
    #
    $self->{tablespace} = undef;

    #$self->process_mix();

    return $self;
}

=head3 plot_tablespaces()

=cut

sub plot_tablespaces {
    my $self = shift;
    my $iostat = shift;

    foreach my $tablespace (sort keys %{$self->{tablespace}}) {
        $iostat->outdir("$self->{outdir}/db/iostat/$tablespace");
        $iostat->plot(@{$self->{tablespace}->{$tablespace}});
    }
}

=head3 to_html()

Create HTML pages.

=cut
sub to_html {
    my $self = shift;

    my $links = '';

    my $q = new CGI;
    my $h = $q->start_html('System Status Collecting Report');

    $h .= $q->h1('Blogbench Test Report');
    $h .= $q->p($self->{xml}->{date});
    
    $h .= $q->h2('System Statistics');
    #
    # vmstat links
    #
    my $vmstat1 = Test::Webbench::Vmstat->new(
            $self->{xml}->{system}->{driver}->{vmstat});
    $vmstat1->outdir("$self->{outdir}/vmstat");
    $vmstat1->plot();
    my $driver = $vmstat1->to_html("vmstat");
    my $db = '';
    my $col_header = '';
    my $vmstat2;
    if ($self->{xml}->{system}->{db}->{vmstat}) {
        $vmstat2 = Test::Presenter::Vmstat->new(
                $self->{xml}->{system}->{db}->{vmstat});
        $vmstat2->outdir("$self->{outdir}/db/vmstat");
        $vmstat2->plot();
        $vmstat2->header(0);
        $db = $vmstat2->to_html("db/vmstat");
        $col_header = $q->th('Driver System') . $q->th('Database System');
    } else {
        $col_header = $q->th('Single System');
    }
    $h .= $q->p(
            $q->table(
                    $q->caption('vmstat') .
                    $q->Tr($col_header) .
                    $q->Tr($q->td({valign => 'top'}, $driver) .
                            $q->td({valign => 'top'}, $db))));
    #
    # iostat links
    #
    my $iostat1 = Test::Webbench::Iostat->new(
            $self->{xml}->{system}->{driver}->{iostat});
    $iostat1->outdir("$self->{outdir}/iostat");
    $db = '';
    my $iostat2;
    if ($self->{xml}->{system}->{db}->{iostat}) {
        $iostat1->plot();
        $iostat2 = Test::Presenter::Iostat->new(
                $self->{xml}->{system}->{db}->{iostat});
        $iostat2->header(0);
        if ($self->{tablespace}) {
            $self->plot_tablespaces($iostat2);
            $db = $q->table($self->html_tablespaces($iostat2));
            #
            # Do this so the tables line up with the captions from the
            # tablespaces.
            #
            $iostat1->caption('driver');
        } else {
            $iostat2->outdir("$self->{outdir}/db/iostat");
            $iostat2->plot();
            $db = $iostat2->to_html("db/iostat");
        }
        $driver = $iostat1->to_html("iostat");
        $col_header = $q->th('Driver System') . $q->th('Database System');
    } else {
        if ($self->{tablespace}) {
            $iostat1->caption('all');
            $iostat1->outdir("$self->{outdir}/iostat");
            $iostat1->plot();
            $driver = $iostat1->to_html("iostat");
            $iostat1->header(0);
            $self->plot_tablespaces($iostat1);
            $db = $self->html_tablespaces($iostat1);
        } else {
            $iostat1->plot();
            $driver = $iostat1->to_html("iostat");
            $col_header = $q->th('Single System');
        }
    }
    $h .= $q->p(
            $q->table(
                    $q->caption('iostat') .
                    $q->Tr($col_header) .
                    $q->Tr($q->td({valign => 'top'}, $driver) .
                            $q->td({valign => 'top'}, $db))));

    $h .= $q->end_html;
       
    return $h;
}

sub html_tablespaces {
    my $self = shift;
    my $iostat = shift;

    my $q = new CGI;
    my $h = '';
    foreach my $tablespace (sort keys %{$self->{tablespace}}) {
        $iostat->caption($tablespace);
        $h .= $q->td($iostat->to_html("db/iostat/$tablespace"));
    }
    return $h;
}


=head3 image_check()

Returns an HTML href a file exists.

=cut
sub image_check {
    my $self = shift;
    my $filename = shift;
    my $link = shift;

    my $q = new CGI;

    $filename =~ /.*\.(.*)/;
    my $format = $1;

    my $h = '';
    if (-f "$self->{outdir}/$filename") {
        $h .= $q->a({href => $filename}, $q->img({src => $filename,
                height => 96, width => 128}));
    }
    return $h;
}

sub outdir {
    my $self = shift;
    if (@_) {
        $self->{outdir} = shift;
        $self->{datadir} = "$self->{outdir}/..";
    }
    return $self->{outdir};
}

1;
__END__

=head1 AUTHOR

Mark Wong <markwkm@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2006-2008 Mark Wong & Open Source Development Labs, Inc.
All Rights Reserved.

This script is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 SEE ALSO

L<Test::Webbench>

=end

