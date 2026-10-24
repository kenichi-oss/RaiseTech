variables{
    #instance_type = "t2.micro"
}

run "valid_string_concat_ec2_instance_type" {
    command = plan

    assert {
        condition   = output.ec2_instance_type == "t2.micro"
        error_message = "EC2 instance type does not match the expected value."
    }
}
run "valid_string_concat_rds_storage_type" {
    command = plan
    assert {
        condition  = output.storage_type == "gp2"
        error_message = "RDS storage type does not match the expected value."
    }
}
run "valid_string_concat_rds_engine" {
    command = plan
    assert {
        condition  = output.engine == "mysql"
        error_message = "RDS engine does not match the expected value."
    }
}

