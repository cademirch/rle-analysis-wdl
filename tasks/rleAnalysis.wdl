version 1.0

task measure_runlength_dist {
    input {
        File ref
        File seqs
        String outputPrefix = basename(seqs, ".fasta")

        Int memoryPerThreadGb = 4
        Int threads = 1
        Int memoryGb = 1 + threads * memoryPerThreadGb
        Int timeMinutes = 1 + ceil(size(seqs, "GiB") * 3)
        String dockerImage = "docker.io/cademirch/rle-analysis:latest"

    }

    command {
        set -e
        mkdir -p "$(dirname ~{outputPrefix})"
        measure_runlength_distribution_from_fasta \
            --minimap_preset map-ont \
            --max_threads 92 \
            --minimum_match_length 11 \
            --output_dir ~{outputPrefix} \
            --ref ~{ref} \
            --sequences ~{seqs}
    }

    output {
        File distFile = outputPrefix + "/length_frequency_matrix_nondirectional.csv"
    }

    runtime {
        cpu: threads
        memory: "~{memoryGb}GiB"
        time_minutes: timeMinutes
        docker: dockerImage
    }
}


task convert_matrix_shasta_config {
    input {
        File distFile
        String name
        Int pseudocount = 10
        
        String outputFile = sub(distFile, "/length_frequency_matrix_nondirectional.csv", "/shasta_bayesian_config_nondirectional_zero-fix") 
        

        Int memoryPerThreadGb = 4
        Int threads = 1
        Int memoryGb = 1 + threads * memoryPerThreadGb
        Int timeMinutes = 1 + ceil(size(distFile, "GiB") * 3)
        String dockerImage = "docker.io/cademirch/rle-analysis:latest"

    }

    command {
        set -e
        python3 /workdir/scripts/convert_frequency_matrix_to_shasta_config.py \
        --prior human \
        --name ~{name} \
        --input ~{distFile} \
        --output ~{outputFile} \
        --pseudocount ~{pseudocount}
    }

    output {
        File configFile = outputFile + "/length_frequency_matrix_nondirectional_shasta_bayesian_config.csv"
    }

    runtime {
        cpu: threads
        memory: "~{memoryGb}GiB"
        time_minutes: timeMinutes
        docker: dockerImage
    }
}