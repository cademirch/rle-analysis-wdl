version 1.0
import "tasks/splitBam.wdl" as sp
import "tasks/rleAnalysis.wdl" as rle
import "tasks/shasta.wdl" as shasta
import "tasks/mm2.wdl" as mm2
import "tasks/quast.wdl" as quast
import "tasks/samtools.wdl" as samtools

workflow align{
    input {
        File referenceFile
        Array[File] queryFiles
        String runName
        String testChroms = "S6 S16" # space delimited list of chromosomes for test set
        String trainChroms = "S1 S2 S3 S4 S5 S7 S8 S9 S10 S11 S12 S13 S14 S15 S17 S18 S19 S20 S21 S22 SX SY" # space delimited list of chromosomes for train set
    }
    
    call mm2.Mapping as map{
        input:
            referenceFile = referenceFile,
            queryFile = queryFiles,
            outputPrefix = runName,
            presetOption = "map-ont",
            outputSam = true,
            secondaryAlignment = false
    }

    call samtools.Sort as sort{
        input:
            inputBam = map.alignmentFile,
            outputPath = basename(map.alignmentFile, "\.bam") + ".sorted.bam"           
    }

    call sp.splitBamToFasta as testFasta{
        input:
            inputBam = sort.outputBam,
            inputBamIndex = sort.outputBamIndex,
            label = "test",
            region = testChroms
    }

    call sp.splitBamToFasta as trainFasta{
        input:
            inputBam = sort.outputBam,
            inputBamIndex = sort.outputBamIndex,
            label = "train",
            region = trainChroms
    }

    call rle.measure_runlength_dist as measureRawRLE{
        input:
            ref = referenceFile,
            seqs = trainFasta.outputFasta,
            
    }
    
    call rle.convert_matrix_shasta_config as convertMatrix{
        input:
            distFile = measureRawRLE.distFile,
            name = runName
    }
    
    call shasta.shasta as shastaAssembleBayesian {
        input:
            inFasta = testFasta.outputFasta,
            bayesianConfigFile = convertMatrix.configFile,
            consensusCallerMode = "Bayesian:",
            assemblyDirectory = runName + "_assembly_bayesian"
    }

    call shasta.shasta as shastaAssembleModal {
        input:
            inFasta = testFasta.outputFasta,
            consensusCallerMode = "Modal",
            assemblyDirectory = runName + "_assembly_modal"
    }

    call quast.quast as quastBayesian {
        input:
            referenceFile = referenceFile,
            assembly = shastaAssembleBayesian.assembly
    }

    call quast.quast as quastModal {
        input:
            referenceFile = referenceFile,
            assembly = shastaAssembleModal.assembly
    }

    call rle.measure_runlength_dist as measureBayesianRLE{
        input:
            ref = referenceFile,
            seqs = shastaAssembleBayesian.assembly,
            
    }

    call rle.measure_runlength_dist as measureModalRLE{
        input:
            ref = referenceFile,
            seqs = shastaAssembleModal.assembly,
            
    }
    
    call rle.plot as plotResults {
        input:
            distFiles = [measureRawRLE.distFile, measureBayesianRLE.distFile, measureModalRLE.distFile],
            labels = ["Raw", "Bayesian", "Modal"]
    }
    output {
        File plot = plotResults.png
        Array[File] quastTsvReports = [quastModal.reportTsv, quastBayesian.reportTsv]
        Array[File] quastHtmlReports = [quastModal.reportHtml, quastBayesian.reportHtml]
    }

}