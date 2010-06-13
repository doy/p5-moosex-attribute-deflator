package MooseX::Attribute::LazyInflator::Meta::Role::Attribute;

# ABSTRACT: Lazy inflate attributes
use Moose::Role;
use strict;
use warnings;
with 'MooseX::Attribute::Deflator::Meta::Role::Attribute';

override _coerce_and_verify => sub {
    my ($self, $value, $instance) = @_;
    return $value unless($instance->_inflated_attributes && $instance->_inflated_attributes->{$self->name});
    super();
};

before get_value => sub {
    my ($self, $instance) = @_;
    return if(!$self->has_value($instance));
    return if($instance->_inflated_attributes->{$self->name}++);
    $self->set_value($instance, $self->inflate($instance, $self->get_raw_value($instance)));
};

use MooseX::Attribute::LazyInflator::Meta::Role::Method::Accessor;
sub accessor_metaclass { 'MooseX::Attribute::LazyInflator::Meta::Role::Method::Accessor' }


1;

__END__

=head1 SYNOPSIS

  package Test;

  use Moose;
  use MooseX::Attribute::LazyInflator;
  # Load default deflators and inflators
  use MooseX::Attribute::Deflator::Moose;

  has hash => ( is => 'rw', 
               isa => 'HashRef',
               traits => ['LazyInflator'] );

  package main;
  
  my $obj = Test->new( hash => '{"foo":"bar"}' );
  # Attribute 'hash' is being inflated to a HashRef on access
  $obj->hash;

=head1 ROLES

This role consumes L<MooseX::Attribute::Deflator::Meta::Role::Attribute>.

=head1 METHODS

=over 8

=item before B<get_value>

The attribute's value is being inflated and set if it has a value and hasn't been inflated yet.

=item override B<_coerce_and_verify>

Coercion and type constraint verification is not processed if the
attribute has not been inflated yet.

=back

=head1 FUNCTIONS

=over 8

=item B<accessor_metaclass>

The accessor metaclass is set to L<MooseX::Attribute::LazyInflator::Meta::Role::Method::Accessor>.

=back