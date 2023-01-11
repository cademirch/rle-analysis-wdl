version 1.0
import "https://raw.githubusercontent.com/biowdl/tasks/develop/minimap2.wdl" as minimap2
import "https://raw.githubusercontent.com/biowdl/tasks/develop/samtools.wdl" as samtools
import "tasks/splitBam.wdl" as sp
import "tasks/rleAnalysis.wdl" as rle
import "tasks/shasta.wdl" as shasta

workflow align{
    input {
        File referenceFile
        Array[File] queryFiles
        
        String testChroms = "chr1" # space delimited list of chromosomes for test set
        String trainChroms = "chr2" # space delimited list of chromosomes for train set
    }
    scatter (queryFile in queryFiles) {
        String runName = basename(queryFile, ".fastq") # name of run to be used downstream
        call minimap2.Mapping {
            input:
                referenceFile = referenceFile,
                queryFile = queryFile,
                outputPrefix = runName,
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

        call rle.measure_runlength_dist as measureRLE{
            input:
                ref = referenceFile,
                seqs = trainFasta.outputFasta,
                
        }
        
        call rle.convert_matrix_shasta_config as convertMatrix{
            input:
                distFile = measureRLE.distFile,
                name = runName
        }

        call shasta.shasta as shastaAssemble {
            input:
                inFasta = testFasta.outputFasta,
                distConf = convertMatrix.configFile,
                assemblyDirectory = runName + "_assembly"
        }

    }
    call rle.plot_matrix as plot{
            input:
                distFiles = measureRLE.distFile,
                labels = runName
        }
    
    
}