; movement.g
; Configure motion-specific parameters, enabling segmentation
; to allow faster pauses and position reporting.
; K0 = Cartesian movement mode
M669 K0 S{global.segmentsPerSecond} T{global.minSegmentLength}
M118 P0 L2 S{"Enabling segmentation, segments per second: " ^ global.segmentsPerSecond ^ ", min segment length: " ^ global.minSegmentLength}