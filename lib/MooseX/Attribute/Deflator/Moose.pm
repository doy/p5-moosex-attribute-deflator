package MooseX::Attribute::Deflator::Moose;
# ABSTRACT: Deflators for Moose type constraints

use MooseX::Attribute::Deflator;
use JSON;


deflate 'HashRef', via { JSON::encode_json($_) };
inflate 'HashRef', via { JSON::decode_json($_) };

deflate 'ArrayRef', via { JSON::encode_json($_) };
inflate 'ArrayRef', via { JSON::decode_json($_) };

deflate 'ScalarRef', via { $$_ };
inflate 'ScalarRef', via { \$_ };

deflate 'Item', via { $_ };
inflate 'Item', via { $_ };

deflate 'HashRef[]', via {
    my ($attr, $constraint, $deflate) = @_;
    my $value = {%$_};
    while(my($k,$v) = each %$value) {
        $value->{$k} = $deflate->($value->{$k}, $constraint->type_parameter);
    }
    return $deflate->($value, $constraint->parent);
};

inflate 'HashRef[]', via {
    my ($attr, $constraint, $inflate) = @_;
    my $value = $inflate->($_, $constraint->parent);
    while(my($k,$v) = each %$value) {
        $value->{$k} = $inflate->($value->{$k}, $constraint->type_parameter);
    }
    return $value;
};

deflate 'ArrayRef[]', via {
    my ($attr, $constraint, $deflate) = @_;
    my $value = [@$_];
    $_ = $deflate->($_, $constraint->type_parameter) for(@$value);
    return $deflate->($value, $constraint->parent);
};

inflate 'ArrayRef[]', via {
    my ($attr, $constraint, $inflate) = @_;
    my $value = $inflate->($_, $constraint->parent);
    $_ = $inflate->($_, $constraint->type_parameter) for(@$value);
    return $value;
};

deflate 'Maybe[]', via {
    my ($attr, $constraint, $deflate) = @_;
    return $deflate->($_, $constraint->type_parameter);
};

inflate 'Maybe[]', via {
    my ($attr, $constraint, $inflate) = @_;
    return $inflate->($_, $constraint->type_parameter);
};

deflate 'ScalarRef[]', via {
    my ($attr, $constraint, $deflate) = @_;
    return ${$deflate->($_, $constraint->type_parameter)};
};

inflate 'ScalarRef[]', via {
    my ($attr, $constraint, $inflate) = @_;
    return \$inflate->($_, $constraint->type_parameter);
};

1;

__END__

=head1 SYNOPSIS

  use MooseX::Attribute::Deflator::Moose;
  
=head1 DESCRIPTION

Using this module registers sane type deflators and inflators for Moose's built in types.

Some notes:

=over

=item * HashRef and ArrayRef deflate/inflate using JSON

=item * ScalarRef is dereferenced on deflation and returns a reference on inflation

=back