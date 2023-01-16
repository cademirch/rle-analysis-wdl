version 1.0

task shasta {
    input {
        File inFasta
        File bayesianConfigFile = ""
        String consensusCallerMode
        String assemblyDirectory
        String config = "Nanopore-May2022"
        String memoryMode ="anonymous"
        String memoryBacking = "4K"

        
        String dockerImage = "docker.io/cademirch/shasta:latest"
        Int cores = 4
        String memory = "30GiB"
    }
    command {
        set -e
        shasta \
        --input ~{inFasta} \
        --config ~{config} \
        --memoryMode ~{memoryMode} \
        --memoryBacking ~{memoryBacking} \
        --assemblyDirectory ~{assemblyDirectory} \
        --Assembly.consensusCaller ~{consensusCallerMode}~{bayesianConfigFile}
    }

    output {
        File assembly = assemblyDirectory + "/Assembly.fasta"
    }

    runtime {
        cpu: cores
        memory: memory
        docker: dockerImage
    }


}