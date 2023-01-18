version 1.0

task quast {

    input {
        File referenceFile
        File assembly
        Int minIndentity = 80
        String outputDir = "quast_out"
        
        String dockerImage = "docker.io/cademirch/quast:latest"
        Int cores = 4
        String disks = "local-disk 500 SSD"
        String memory = "30GiB"
    }

    command {
        set -e
        quast.py \
        -o ~{outputDir} \
        --threads ~{cores} \
        -r ~{referenceFile} \
        --large \
        --min-identity ~{minIndentity} \
        --fragmented ~{assembly}
    }
    output {
        File reportTsv = outputDir + "/report.tsv"
        File reportHtml = outputDir + "/report.html"
    }
    runtime {
        cpu: cores
        memory: memory
        disks: disks
        docker: dockerImage
    }

    

}