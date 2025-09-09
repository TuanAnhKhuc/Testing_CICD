##############################################
# RDS module outputs - outputs.tf            #
##############################################

output "rds_endpoint" { value = aws_db_instance.mysql.address }
