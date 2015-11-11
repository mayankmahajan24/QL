OCAMLC=ocamlc
OCAMLDEP=ocamldep
OCAMLLEX=ocamllex
OCAMLYACC=ocamlyacc
OBJS=ast.cmo parser.cmo scanner.cmo ql.cmo

ql: $(OBJS)
	ocamlc -o ql $(OBJS)

scanner.ml: scanner.mll
	$(OCAMLLEX) scanner.mll

parser.ml parser.mli: parser.mly
	$(OCAMLYACC) parser.mly

%.cmo : %.ml
	ocamlc -w A -c $<

%.cmi : %.mli
	ocamlc -w A -c $<

.PHONY: clean
clean:
	rm -rf scanner.ml parser.ml parser.mli *.cmo *.cmi *.out *.diff

ast.cmo :
ast.cmx :
ql.cmo : ast.cmo
ql.cmx : ast.cmx