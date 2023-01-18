version 1.0
task Sort {
    input {
        File inputBam
        String outputPath = basename(inputBam, "\.bam") + ".sorted.bam"
        Boolean sortByName = false
        Int compressionLevel = 1

        Int memoryPerThreadGb = 4
        Int threads = 1
        Int memoryGb = 1 + threads * memoryPerThreadGb
        String disks = "local-disk 500 SSD"
        String dockerImage = "quay.io/biocontainers/samtools:1.16.1--h6899075_1"
    }

    # Select first needed as outputPath is optional input (bug in cromwell).
    String bamIndexPath = sub(select_first([outputPath]), "\.bam$", ".bai")

    command {
        set -e
        mkdir -p "$(dirname ~{outputPath})"
        samtools sort \
        -l ~{compressionLevel} \
        ~{true="-n" false="" sortByName} \
        ~{"--threads " + threads} \
        -m ~{memoryPerThreadGb}G \
        -o ~{outputPath} \
        ~{inputBam}
        samtools index \
        -@ ~{threads} \
        ~{outputPath} ~{bamIndexPath}
    }

    output {
        File outputBam = outputPath
        File outputBamIndex = bamIndexPath
    }

    runtime {
        cpu: threads
        memory: "~{memoryGb}GiB"
        disks: disks
        docker: dockerImage
    }
}