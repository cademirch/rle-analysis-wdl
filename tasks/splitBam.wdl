version 1.0

task splitBamToFasta {
    input {
        File inputBam
        File inputBamIndex
        String label # for labelling output as train or test
        String outputFilePath = basename(inputBam, ".sorted.bam") + "." + label + ".fasta"
        String region

        Int memoryPerThreadGb = 4
        Int threads = 1
        Int memoryGb = 1 + threads * memoryPerThreadGb
        Int timeMinutes = 1 + ceil(size(inputBam, "GiB") * 3)
        String dockerImage = "quay.io/biocontainers/samtools:1.11--h6270b1f_0"
    }

    command {
        set -e
        mkdir -p "$(dirname ~{outputFilePath})"
        samtools view -bh \
        ~{inputBam} \
        ~{region} | samtools fasta - -0 ~{outputFilePath}
    }

    output {
        File outputFasta = outputFilePath
    }

    runtime {
        cpu: threads
        memory: "~{memoryGb}GiB"
        time_minutes: timeMinutes
        docker: dockerImage
    }
}