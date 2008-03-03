package Catalyst::View::CSV;

use strict;
use warnings;
use base qw( Catalyst::View );
use Catalyst::Exception;
use Text::CSV;

=head1 NAME

Catalyst::View::CSV - Comma separated values or Delimiter separated values for your data 

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

sub process {
my ($self, $c) = @_;
  my $template = $c->stash->{template};
  my $content = $self->render($c, $template, $c->stash);

  $c->res->headers->header("Content-Type" => "text/csv") if($c->res->headers->header("Content-Type") eq "");
  $c->res->body( $content );
}

sub render {
  my ($self, $c, $template, $args) = @_;

  my $content;

  my $quote_char = (defined($args->{'quote_char'})) ? $args->{'quote_char'} : '"';
  my $escape_char = (defined($args->{'escape_char'})) ? $args->{'escape_char'} : '"';
  my $sep_char = (defined($args->{'sep_char'})) ? $args->{'sep_char'} : ',';
  my $eol = (defined($args->{'eol'})) ? $args->{'eol'} : "\n";

  if(defined($args->{csv}) && ref($args->{csv}) =~ /ARRAY/) {
    $content = $self->_csv($quote_char, $escape_char, $sep_char, $eol, $c->stash->{csv});
  }
  else {
    my @data;
    foreach my $key(%{$args}) {
      if(ref($args->{$key}) =~ /ARRAY/) {
        push(@data,@{$args->{$key}});
      }
    }

    $content = $self->_csv($quote_char, $escape_char, $sep_char, $eol, \@data);
  }

  return $content;
}

sub _csv {
  my ($self, $quote_char, $escape_char, $sep_char, $eol, $data) = @_;

  my $content;

  my $csv = Text::CSV->new ({
     quote_char          => $quote_char,
     escape_char         => $escape_char,
     sep_char            => $sep_char,
     eol                 => $eol,
     binary              => 1,
     allow_loose_quotes  => 1,
     allow_loose_escapes => 1,
     allow_whitespace    => 1,
  });

  foreach my $row(@{$data}) {
    $row = [$row] if(ref($row) !~ /ARRAY/);

    my $status = $csv->combine(@{$row});
    Catalyst::Exception->throw("Text::CSV->combine Error: ".$csv->error_diag()) if(!$status);
    $content .= $csv->string();
  }

  return $content;
}

=head1 SYNOPSIS

  # lib/MyApp/View/CSV.pm
  package MyApp::View::CSV;
  use base qw( Catalyst::View::CSV );
  1;

  # lib/MyApp/Controller/SomeController.pm
  sub example_action_1 : Local {
    my ($self, $c) = @_;
  
    # Array reference of array references.
    my $data = [
      ['col 1','col 2','col ...','col N'], # row 1
      ['col 1','col 2','col ...','col N'], # row 2
      ['col 1','col 2','col ...','col N'], # row ...
      ['col 1','col 2','col ...','col N']  # row N
    ];

    # To output your data in comma seperated values just pass your array by reference into the 'csv' key of the stash
    $c->stash->{'csv'} = $data;

    # Finally forward processing to the CSV View
    $c->forward('MyApp::View::CSV');
  }

  # Other ways of storing data
  sub example_action_2 : Local {
    my ($self, $c) = @_;

    # Array of array references
    my @data;

    push(@data,['col 1','col 2','col ...','col N']); # row 1
    push(@data,['col 1','col 2','col ...','col N']); # row 2
    push(@data,['col 1','col 2','col ...','col N']); # row ...
    push(@data,['col 1','col 2','col ...','col N']); # row N

    # OR to produce a single column of data you can simply do the following 
    my @data = (
                'col 1 row 1',
                'col 1 row 2',
                'col 1 row ...',
                'col 1 row N'
               );

    $c->stash->{'csv'} = \@data;

    $c->forward('MyApp::View::CSV');
  }

  # Available Options to produce other types of delimiter seperated output
  sub  example_action_3 : Local {
    my ($self, $c) = @_;

    my $data = [
      ['col 1','col 2','col ...','col N'], # row 1
      ['col 1','col 2','col ...','col N'] # row 2
    ];

    # You can change any of the aspects of a delimiter seperated values format by storing them in the appropriate stash key
    # This is an example of tab seperated values for instance

    $c->stash->{'quote_char'} = '"'; # default: '"'

    $c->stash->{'escape_char'} = '"'; # default: '"'

    $c->stash->{'sep_char'} = '\t'; # default: ','

    $c->stash->{'eol'} = "\n"; # default: "\n"

    $c->stash->{'csv'} = $data;
  }

=head1 MIME MEDIA TYPE

If the Content-Type HTTP Header is not set, it will default to 'text/csv'.

  # Example of setting your own Content-Type
  $c->res->headers->header('Content-Type' => 'text/plain');

  # Forward processing to CSV View with a text/plain Content-Type
  $c->forward("MyApp::View::CSV");

=head1 OPTIONS

=over 4

=item quote_char

Determines what value will be enclosed within if it contains whitespace or the delimiter character. DEFAULT: '"'

  $c->stash->{'quote_char'} = '/';

=item escape_char

Determines what value will be to escape any delimiter's found in a column. DEFAULT: '"'

  $c->stash->{'escape_char'} = '/';

=item sep_char

Determines the separator between columns. DEFAULT: ','

  $c->stash->{'sep_char'} = '|';

=item eol

Any characters defined in eol will be placed at the end of a row. DEFAULT: '\n'

  $c->stash->{'eol'} = '\0';

=item csv

The data that will be processed into delimiter separated values format is stored here. The data should be an array ref of array refs of scalars or an array ref of scalars. Note: if nothing is found in csv, the stash is searched and any array references found will be used as the data instead.

  # Array ref of array refs of scalars
  my $data = [
    ['apple','banana','pear'],
    ['red','yellow','green']
  ];

  $c->stash->{csv} = $data;

  # Array ref of scalars
  my @data = ('Jan','Feb','Mar','Apr');
 
  $c->stash->{csv} = \@data;

=back

=head1 SUBROUTINES

=over 4

=item process

This method will be called by Catalyst if it is asked to forward to a component without a specified action.

=item render

Allows others to use this view for much more fine-grained content generation.

=item _csv

Subroutine that actually produces the delimiter separated values. Intended to be private in scope to this module.

=back

=head1 AUTHOR

Travis Chase, C<< <gaudeon at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-catalyst-view-csv at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Catalyst-View-CSV>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Catalyst::View::CSV


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Catalyst-View-CSV>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Catalyst-View-CSV>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Catalyst-View-CSV>

=item * Search CPAN

L<http://search.cpan.org/dist/Catalyst-View-CSV>

=back

=head1 SEE ALSO

L<Catalyst> L<Text::CSV>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Travis Chase, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Catalyst::View::CSV
