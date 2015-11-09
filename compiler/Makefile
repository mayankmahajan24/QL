OCAMLC=ocamlc
OCAMLDEP=ocamldep
OCAMLLEX=ocamllex
OCAMLYACC=ocamlyacc

main: scanner parser

scanner: scanner.mll
	$(OCAMLLEX) scanner.mll

parser: parser.mly
	$(OCAMLYACC) parser.mly

.PHONY: clean
clean:
	rm -rf scanner.ml parser.ml parser.mli *.cmo *.cmi *.out *.diff