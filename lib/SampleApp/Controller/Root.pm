package SampleApp::Controller::Root;
use Ark 'Controller';

has '+namespace' => default => '';

# default 404 handler
sub default :Path :Args {
    my ($self, $c) = @_;

    $c->res->status(404);
    $c->res->body('404 Not Found');
}

sub index :Path :Args(0) {
    my ($self, $c) = @_;
}

sub login :Path('login') :Args(0) {
    my ($self, $c) = @_;
    if(!$c->req->method eq "POST" || $c->authenticate){
        # ログイン成功
        $c->redirect_and_detach($c->uri_for('/loggedin'));
    }
    # ログイン失敗
    $c->redirect_and_detach($c->uri_for('/'));
}

sub logout :Path('logout') :Args(0) {
    my ($self, $c) = @_;
    $c->logout;
    $c->redirect_and_detach($c->uri_for('/'));
}

# ログイン済み
sub loggedin :Path('loggedin') :Args(0) {
    my ($self, $c) = @_;
    
    # ログインしていない場合はログイン画面へ
    $c->redirect_and_detach($c->uri_for('/')) if(!$c->user);

    $c->stash->{id} = $c->user->hash->{id};
}

sub end :Private {
    my ($self, $c) = @_;

    unless ($c->res->body or $c->res->status =~ /^3\d\d/) {
        $c->forward( $c->view('Tiffany') );
    }
}

1;
