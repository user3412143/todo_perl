package db_work;
use DBI;

sub db_initialization {
	my $dbh = DBI->connect("dbi:SQLite:dbname=task_db","","",
		{RaiseError => 1, PrintError =>0});

	$dbh->do("CREATE TABLE IF NOT EXISTS task (
		id INTEGER PRIMARY KEY,
		status TEXT,
		task_description TEXT)");
	return $dbh;
}

sub get_tasks {
	$dbh = &db_initialization;
	my $state= $dbh->prepare("SELECT id, task_description FROM task");
	$state->execute();

	my %task_hash;
	while (my ($id, $task_description) = $state->fetchrow_array()) {
		$task_hash{$id} = $task_description;
	}
	$dbh->disconnect();
	return %task_hash;
}

sub add_task {
	$dbh = &db_initialization;
	my ($status, $task_description) = @_;
	my $state = $dbh->prepare("INSERT INTO task (status, task_description) VALUES (?, ?)");
	$state->execute($status, $task_description);
	$dbh->disconnect();
}

sub remove_task {
	my $id = shift;
	$dbh = &db_initialization;
	my $state = $dbh->prepare("DELETE FROM task WHERE id = ?");
	$state->execute($id);
	$dbh->disconnect();
}
1;
