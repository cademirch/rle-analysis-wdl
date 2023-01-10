version 1.0
import "https://raw.githubusercontent.com/biowdl/tasks/develop/minimap2.wdl" as minimap2
import "https://raw.githubusercontent.com/biowdl/tasks/develop/samtools.wdl" as samtools
import "tasks/splitBam.wdl" as sp
import "tasks/rleAnalysis.wdl" as rle
import "tasks/shasta.wdl" as shasta

workflow align{
    input {
        File referenceFile
        File queryFile
        String runName = basename(queryFile, ".fastq") # name of run to be used downstream
        String testChroms = "PR.57.5.398.0" # space delimited list of chromosomes for test set
        String trainChroms = "PR.57.5.398.1" # space delimited list of chromosomes for train set
    }

    call minimap2.Mapping {
        input:
            referenceFile = referenceFile,
            queryFile = queryFile,
            outputPrefix = basename(queryFile, ".fastq"),
            presetOption = "map-ont",
            outputSam = true
    }

    call samtools.Sort {
        input:
            inputBam = Mapping.alignmentFile,           
    }

    call sp.splitBamToFasta as testFasta{
        input:
            inputBam = Sort.outputBam,
            inputBamIndex = Sort.outputBamIndex,
            label = "test",
            region = testChroms
    }

    call sp.splitBamToFasta as trainFasta{
        input:
            inputBam = Sort.outputBam,
            inputBamIndex = Sort.outputBamIndex,
            label = "train",
            region = trainChroms
    }

    call rle.measure_runlength_dist as mrd{
        input:
            ref = referenceFile,
            seqs = trainFasta.outputFasta,
            
    }

    call rle.convert_matrix_shasta_config as cmsc{
        input:
            distFile = mrd.distFile,
            name = runName
    }

    call shasta.shasta as sh {
        input:
            inFasta = testFasta.outputFasta,
            distConf = cmsc.configFile,
            assemblyDirectory = "assembly_out"
    }
    
    output {
        File distFile = mrd.distFile
        File shastaConfig = cmsc.configFile
        File assembly = sh.assembly
    }

}