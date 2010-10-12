my $home = SampleApp::Models->get('home');

return {
    cache => {
        share_file     => $home->file('tmp', 'cache')->stringify,
        unlink_on_exit => 0,
    },
};
