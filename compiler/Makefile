

main: scanner parser

scanner:
	ocamllex scanner.mll

parser:
	ocamlyacc parser.mly

clean:
	rm -rf scanner.ml parser.ml parser.mli
