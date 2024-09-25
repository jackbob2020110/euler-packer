function add-vagrant-box {
    param (
        $Name,
        $BoxPath
    )
    
    vagrant box add --name $Name $BoxPath
}

function del-vagrant-box {
    param (
        $Name,
        [switch]$Force
    )
    
    if (condition) {
        vagrant box remove --name $Name -f
    }
    else {
        vagrant box remove --name $Name
    }
    
}

function list-vagrant-boxes {
    param (
        
    )
    vagrnat box list
}