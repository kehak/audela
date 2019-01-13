# Lecture de la courbe de lumiere
set curveFileName "famous.dat"
set inputStream [open $curveFileName r]
set allLines [split [read $inputStream] "\n"]
close $inputStream

set minimumOfDates       1e100
set maximumOfDates      -1e100
set kMes                 0

foreach oneLine $allLines {

    if {[string length $oneLine] < 5} { break; }
    
    set dates($kMes)        [lindex $oneLine 0]
    set observations($kMes) [lindex $oneLine 1]
    
    if {$minimumOfDates  > $dates($kMes)} {
        set minimumOfDates $dates($kMes)
    }
    if {$maximumOfDates  < $dates($kMes)} {
        set maximumOfDates $dates($kMes)
    }
    
    incr kMes
}

set numberOfMeasurements $kMes
set totalTimeSpan [expr $maximumOfDates - $minimumOfDates]

# On soustrait la plus petite date et on calcul la moyenne des observations
set meanOfObservations 0.

for {set kMes 0} {$kMes < $numberOfMeasurements} {incr kMes} {

    set dates($kMes) [expr {$dates($kMes) - $minimumOfDates}]
    set meanOfObservations [expr {$meanOfObservations + $observations($kMes)}]
}

set meanOfObservations [expr {$meanOfObservations / $numberOfMeasurements}]

# Definir les frequences balayees
set frequencyUp    24.
set frequencyLow   [expr {1./$totalTimeSpan}]
set deltaFrequency [expr {0.1/$totalTimeSpan}]
set nFrequencies   [expr {1 + int(($frequencyUp - $frequencyLow) / $deltaFrequency)}]
puts -nonewline    "Tests $nFrequencies frequencies\n"

set frequency  $frequencyLow;
set pi         3.1415926535897931
set omega      [expr {2 * $pi * $frequency}]
set deltaOmega [expr {2 * $pi * $deltaFrequency}]

for {set kMes 0} {$kMes < $numberOfMeasurements} {incr kMes} {

    set phase [expr {$omega * $dates($kMes)}]
    set cosPhases($kMes) [expr {cos($phase)}]
    set sinPhases($kMes) [expr {sin($phase)}]
    
    set phase [expr {$deltaOmega * $dates($kMes)}]
    set deltaCosPhases($kMes) [expr {cos($phase)}]
    set deltaSinPhases($kMes) [expr {sin($phase)}]
}

# Debut de la boucle sur les frequences
set indexOfFrequency 1
set bestSpectrum     -1.
set bestFrequency    -1.

while {$indexOfFrequency <= $nFrequencies} {
        
    # Initialise les sommes a 0.
    set coefficientC1 0.
    set coefficientS1 0.
    set coefficientCC 0.
    set coefficientSS 0.
    set coefficientCS 0.
    set coefficientCX 0.
    set coefficientSX 0.
    
    for {set kMes 0} {$kMes < $numberOfMeasurements} {incr kMes} {
        
        set cosPhase $cosPhases($kMes)
        set sinPhase $sinPhases($kMes)
        # C1
        set coefficientC1 [expr {$coefficientC1 + $cosPhase}]
        # S1
        set coefficientS1 [expr {$coefficientS1 + $sinPhase}]
        # CC
        set coefficientCC [expr {$coefficientCC + $cosPhase * $cosPhase}]
        # SS
        set coefficientSS [expr {$coefficientSS + $sinPhase * $sinPhase}]
        # CS
        set coefficientCS [expr {$coefficientCS + $cosPhase * $sinPhase}]
        # CX
        set coefficientCX [expr {$coefficientCX + $cosPhase * $observations($kMes)}]
        # SX
        set coefficientSX [expr {$coefficientSX + $sinPhase * $observations($kMes)}]
    }
    
    # C1
    set coefficientC1 [expr {$coefficientC1 / $numberOfMeasurements}]
    # S1
    set coefficientS1 [expr {$coefficientS1 / $numberOfMeasurements}]
    # CC
    set coefficientCC [expr {$coefficientCC / $numberOfMeasurements - $coefficientC1 * $coefficientC1}]
    # SS
    set coefficientSS [expr {$coefficientSS / $numberOfMeasurements - $coefficientS1 * $coefficientS1}]
    # CS
    set coefficientCS [expr {$coefficientCS / $numberOfMeasurements - $coefficientC1 * $coefficientS1}]
    # CX
    set coefficientCX [expr {$coefficientCX / $numberOfMeasurements - $coefficientC1 * $meanOfObservations}]
    # SX
    set coefficientSX [expr {$coefficientSX / $numberOfMeasurements - $coefficientS1 * $meanOfObservations}]
    # DTMS
    set DTMS          [expr {$coefficientCC * $coefficientSS - $coefficientCS * $coefficientCS}]
    
    # YC
    set coefficientYC [expr {($coefficientSS * $coefficientCX - $coefficientCS * $coefficientSX) / $DTMS}]
    # YS
    set coefficientYS [expr {($coefficientCC * $coefficientSX - $coefficientCS * $coefficientCX) / $DTMS}]
    # spectrum
    set spectrum      [expr {$coefficientYC * $coefficientCX + $coefficientYS * $coefficientSX}]
    
    for {set kMes 0} {$kMes < $numberOfMeasurements} {incr kMes} {
        
        set newCos [expr {$cosPhases($kMes) * $deltaCosPhases($kMes) - $sinPhases($kMes) * $deltaSinPhases($kMes)}]
        if {$newCos > 1.} {
            set newCos 1.
        } elseif {$newCos < -1} {
            set newCos -1
        }
        
        set newSin [expr {$sinPhases($kMes) * $deltaCosPhases($kMes) + $cosPhases($kMes) * $deltaSinPhases($kMes)}]
        if {$newSin > 1.} {
            set newSin 1.
        } elseif {$newSin < -1} {
            set newSin -1
        }

        set cosPhases($kMes) $newCos
        set sinPhases($kMes) $newSin
    }
    
    if {$bestSpectrum   < $spectrum} {
    
        set bestSpectrum  $spectrum
        set bestFrequency $frequency    
    }
    
    set frequency [expr $frequency + $deltaFrequency]
    incr indexOfFrequency
}

puts -nonewline "Best period = [expr 1./$bestFrequency] jour\n"

