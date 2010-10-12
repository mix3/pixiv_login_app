package Ark::Plugin::Authentication::Credential::Pixiv;
use Ark::Plugin 'Auth';

has pixiv_id_field => (
   is       => 'rw',
   isa      => 'Str',
   lazy     => 1,
   default  => sub {
      my $self = shift;
      $self->class_config->{pixiv_id_field} || 'pixiv_id';
   },
);

has pixiv_pass_field => (
   is       => 'rw',
   isa      => 'Str',
   lazy     => 1,
   default  => sub {
      my $self = shift;
      $self->class_config->{pixiv_pass_field} || 'pixiv_pass';
   },
);

around authenticate => sub {
    my $prev = shift->(@_);
    return $prev if $prev;

    my ($self, $info) = @_;

    my $c = $self->context;

    my $id   = $c->req->parameters->{$self->pixiv_id_field};
    my $pass = $c->req->parameters->{$self->pixiv_pass_field};

    return unless ($id or $pass);

    $self->ensure_class_loaded('LWP::UserAgent');
    $self->ensure_class_loaded('HTTP::Request::Common');

    my $url      = 'http://www.pixiv.net/index.php';
    my %formdata = ('mode' => 'login', 'pixiv_id' => $id, 'pass' => $pass, 'skip' => '1');
    my $request  = HTTP::Request::Common::POST($url, [%formdata]);
    my $ua = LWP::UserAgent->new;
    my $res = $ua->request($request);
    my $location = $res->header('Location');
    
    if($location eq 'http://www.pixiv.net/mypage.php'){
        my $user_obj = $self->find_user($id, {id => $id, pass => $pass});
        if ($user_obj) {
            $self->persist_user($user_obj);
            warn "pixiv login";
            return $user_obj;
        }
    }
    warn "pixiv not login...";
    return;
};

1;
