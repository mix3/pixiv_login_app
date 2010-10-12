package SampleApp::Models;
use Ark::Models -base;

register cache => sub {
    my $self = shift;

    my $conf = $self->get('conf')->{cache} || die 'require cache config';

    $self->ensure_class_loaded('Cache::FastMmap');
    Cache::FastMmap->new(%$conf);
};

1;
