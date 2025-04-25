##
## EPITECH PROJECT, 2024
## B-FUN-400-COT-4-1-mypandoc-julcinia.oke
## File description:
## Makefile
##

all :
	stack build
	cp $(shell stack path --local-install-root)/bin/mypandoc-exe \
	./mypandoc

clean :
	stack clean

fclean : clean
	rm -f mypandoc
	rm -r .stack-work

re : fclean all

.PHONY	:	all clean fclean re
