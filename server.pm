use HTTP::Server::Simple::CGI;
use lib '.';
use db_work;

{
package web_server;
use base qw/HTTP::Server::Simple::CGI/;

sub handle_request {
	my ($self, $cgi) = @_;

	if ($cgi->param('add'))  {
		my $task = $cgi->param('task');
		if ($task ge 4) {
			&db_work::add_task("false", $task);
		}
	}
	elsif ($cgi->param('delete'))  {
		my $id = $cgi->param('index');
		&db_work::remove_task($id);
	}
	print "HTTP/1.0 200 OK\r\n";
	print $cgi->header('text/html');
	my $html = read_html_file("index.html");
	my %task_hash = &db_work::get_tasks();
	my $task_list = "";
	my @sorted_keys = sort {$a <=> $b} keys %task_hash;
	# @sorted_keys = map {$_ + 1} @sorted_keys;
	foreach my $id (@sorted_keys) {
		my $task_description = $task_hash{$id};
		$task_list .= "<li> $id: $task_description <a href='/?delete=1&index=$id'>[Delete]</a></li><p>";
	}
	$html =~s|<body>|<body>$task_list|;
	print $html;


}
sub read_html_file {
        my ($filepath) = shift;
        open(my $fh, '<:encoding(utf8)', $filepath) or die "[Error] $!";
        local $/;
        my $content = <$fh>;
        return $content;
}

}
my $pid = web_server->new(8080)->background();
print "A server was running. A process pid:  $pid";
1;
