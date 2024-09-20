
all: deam_nr.newick endo_nr.newick
	echo $< >| all

.PHONY clean:
clean:
	rm endo* deam* Rplots.pdf

%.24.faa %Rplots.pdf: filter.24.R pids.faa hmmer_raw.tsv
	./filter.24.R

%_nr.faa %_nr.faa.clstr: %.24.faa
	cd-hit -i $< -o $@

%_nr.alg.faa: %_nr.faa
	clustalo --auto -i $< -o $@ -v --threads 12

%_nr.newick: %_nr.alg.faa
	FastTree $< >| $@
