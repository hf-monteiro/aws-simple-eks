mysql-dbs = {
    exp = {
        service = "exp",
        engine-version = "8.0.mysql_aurora.3.02.2",
        database-name = "exp",
        snapshot-mode = false
        instance-class = "db.t4g.large"
    }

    whmcs = {
        service = "whmcs",
        engine-version = "8.0.mysql_aurora.3.02.2",
        database-name = "whmcs",
        snapshot-mode = false
        instance-class = "db.t4g.large"
    }
}

cluster-name = "exp-dev"
vpc-name = "exp-dev"