The processor.Z80 board is the central processor for the duodyne system.  It uses a Z80 8-bit CPU and includes dual-DMA channels.  It supports Interrupt Mode 2 (IM2) and an extended memory mapper.

Known Issues
1. Missing pull-up resistors on ~DREQ0 and ~DREQ1

What makes this board "Slick" is the use of two EPM7128S  CPLDs instead of four GAL22V10s for the combinatorial logic.

This project was an experiment to test the viability of using large CPLDs.  Based on results, I decided not to pursue it further.

This project has not been built or tested so use with caution.
