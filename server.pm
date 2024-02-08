use HTTP::Server::Simple::CGI;
use lib '.';
use db_work;

{
package web_server;
use base qw/HTTP::Server::Simple::CGI/;

sub handle_request {
	my ($self, $cgi) = @_;

	my $path = $cgi->path_info();

	# Endpoints
	if ($path eq '/tasks') {
		if ($cgi->request_method() eq 'POST')  {
			my $task = $cgi->param('task');
			if (length $task >= 4) {
				&db_work::add_task("false", $task);
				print "HTTP/1.1 302 Found\r\n";
				print "Location: /\r\n";
				print "\r\n";
			}
		}
		if ($cgi->request_method() eq 'DELETE') {
			my $id = $cgi->param('id');
			&db_work::remove_task($id);
		}
		if ($cgi->request_method() eq 'GET') {
			my %task_hash = &db_work::get_tasks();
			my @tasks = sort {$a <=> $b} values %task_hash;
			for my $task (@tasks) {
				print $task . "\n";
			}
		}
	}
	# an html page who will be showed with default view
	if ($path eq '/') {
		print "HTTP/1.0 200 OK\r\n";
		print $cgi->header('text/html');
		my $html = read_html_file("index.html");
		my %task_hash = &db_work::get_tasks();
		my $task_list = "";
		my @sorted_keys = sort {$a <=> $b} keys %task_hash;
		
		if (@sorted_keys) {
			foreach my $id (@sorted_keys) {
				my $task_description = $task_hash{$id};
				$task_list .= "<li>$id: $task_description
				<a href='#' onclick='delete_task(event, $id)'>[Delete]</a></li><p>";
			}
		} else {
			print "No tasks was found";
		}
		$html =~s|<body>|<body>$task_list|;
		print $html;
	}
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
