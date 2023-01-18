version 1.0

#from https://raw.githubusercontent.com/biowdl/tasks/develop/minimap2.wdl, modified to take array of queryFiles as input
task Mapping {
    input {
        String presetOption
        Int kmerSize = 17
        Boolean skipSelfAndDualMappings = false
        Boolean outputSam = false
        String outputPrefix
        Boolean addMDTagToSam = false
        Boolean secondaryAlignment = false
        File referenceFile
        Array[File] queryFile

        Int? maxIntronLength
        Int? maxFragmentLength
        Int? retainMaxSecondaryAlignments
        Int? matchingScore
        Int? mismatchPenalty
        String? howToFindGTAG

        Int cores = 4
        String memory = "30GiB"
        String disks = "local-disk 500 SSD"
        String dockerImage = "docker.io/staphb/minimap2:latest"
    }

    command {
        set -e
        mkdir -p "$(dirname ~{outputPrefix})"
        minimap2 \
        -x ~{presetOption} \
        -k ~{kmerSize} \
        -n 10 \
        -K 4g \
        -I 8g \
        --cap-kalloc=2000m \
        ~{true="-X" false="" skipSelfAndDualMappings} \
        ~{true="-a" false="" outputSam} \
        -o ~{outputPrefix} \
        ~{true="--MD" false="" addMDTagToSam} \
        --secondary=~{true="yes" false="no" secondaryAlignment} \
        -t ~{cores} \
        ~{"-G " + maxIntronLength} \
        ~{"-F " + maxFragmentLength} \
        ~{"-N " + retainMaxSecondaryAlignments} \
        ~{"-A " + matchingScore} \
        ~{"-B " + mismatchPenalty} \
        ~{"-u " + howToFindGTAG} \
        ~{referenceFile} \
        ${sep=" " queryFile}
    }

    output {
        File alignmentFile = outputPrefix
    }

    runtime {
        cpu: cores
        memory: memory
        disks: disks
        docker: dockerImage
    }

    parameter_meta {
        # inputs
        presetOption: {description: "This option applies multiple options at the same time.", category: "common"}
        kmerSize: {description: "K-mer size (no larger than 28).", category: "advanced"}
        skipSelfAndDualMappings: {description: "Skip self and dual mappings (for the all-vs-all mode).", category: "advanced"}
        outputSam: {description: "Output in the sam format.", category: "common"}
        outputPrefix: {description: "Output directory path + output file prefix.", category: "required"}
        addMDTagToSam: {description: "Adds a MD tag to the sam output file.", category: "common"}
        secondaryAlignment: {description: "Whether to output secondary alignments.", category: "advanced"}
        referenceFile: {description: "Reference fasta file.", category: "required"}
        queryFile: {description: "Input fasta file.", category: "required"}
        maxIntronLength: {description: "Max intron length (effective with -xsplice; changing -r).", category: "advanced"}
        maxFragmentLength: {description: "Max fragment length (effective with -xsr or in the fragment mode).", category: "advanced"}
        retainMaxSecondaryAlignments: {description: "Retain at most N secondary alignments.", category: "advanced"}
        matchingScore: {description: "Matching score.", category: "advanced"}
        mismatchPenalty: {description: "Mismatch penalty.", category: "advanced"}
        howToFindGTAG: {description: "How to find GT-AG. f:transcript strand, b:both strands, n:don't match GT-AG.", category: "common"}
        cores: {description: "The number of cores to be used.", category: "advanced"}
        memory: {description: "The amount of memory available to the job.", category: "advanced"}
        
        dockerImage: {description: "The docker image used for this task. Changing this may result in errors which the developers may choose not to address.", category: "advanced"}

        # outputs
        alignmentFile: {description: "Mapping and alignment between collections of dna sequences file."}
    }
}