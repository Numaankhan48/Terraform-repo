# ✅ Fetch the existing DB instance by name
data "aws_db_instance" "source" {
  db_instance_identifier = "rds-test"
}

# ✅ Create Read Replica
resource "aws_db_instance" "read_replica" {
  identifier          = "rds-test-replica"
  replicate_source_db = data.aws_db_instance.source.id
  instance_class      = "db.t3.micro"
  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "rds-test-replica"
  }
}