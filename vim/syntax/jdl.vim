" Vim syntax file
" Language: JHipster domain language
" Maintainer: Lukas Trumm
" Latest Revision: 2017

if exists("b:current_syntax")
  finish
endif

syn keyword jdlLeadingWord angularSuffix dto entity enum paginate relationship service skipwhite

syn keyword jdlStatement all except infinite-scroll mapstruct max maxbytes maxlength min minbytes minlength pagination pattern required serviceImpl to with

syn keyword jdlType AnyBlob BigDecimal Blob Boolean Date Double Enum Float ImageBlob Integer LocalDate Long String TextBlob UUID ZonedDateTime skipwhite

syn keyword jdlRelation OneToMany ManyToOne OneToOne ManyToMany skipwhite

syn match   jdlConstant "\<[A-Z_]\+\>"
syn match   jdlNumber   "\<\d\+\>"
syn match   jdlStar     " \* "

syn match   jdlComment        "//.*$"
syn region  jdlJavaDocComment start="/\*\*" end="\*/" keepend

hi def link jdlLeadingWord      Type
hi def link jdlStatement        Statement
hi def link jdlStar             Statement
hi def link jdlType             Constant
hi def link jdlRelation         Statement
hi def link jdlConstant         PreProc
hi def link jdlNumber           Special
hi def link jdlComment          Comment
hi def link jdlJavaDocComment   Comment

