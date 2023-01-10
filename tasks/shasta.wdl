version 1.0

task shasta {
    input {
        File inFasta
        File distConf
        String assemblyDirectory
        String config = "Nanopore-May2022"
        String memoryMode ="anonymous"
        String memoryBacking = "4K"

        
        String dockerImage = "docker.io/cademirch/shasta:latest"
    }
    command {
        set -e
        shasta \
        --input ~{inFasta} \
        --config ~{config} \
        --memoryMode ~{memoryMode} \
        --memoryBacking ~{memoryBacking} \
        --assemblyDirectory ~{assemblyDirectory} \
        --Assembly.consensusCaller Bayesian:~{distConf}
    }

    output {
        File assembly = assemblyDirectory + "/Assembly.fasta"
    }

    runtime {
        docker: dockerImage
    }


}