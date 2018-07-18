/* copyright 1996, Jason Hunt and Washington Univ., St. Louis */
int          IsTypeSymbol(char *);
Symbol      *EnterSymbol(MimeType, char *);
Symbol      *LookupSymbol(int, char *);
Symbol      *RetrieveSymbol(char *);
Symbol      *FindSymbol(int, char *);
void         PrintSymbol(Symbol *);
void         ForEachSymbol(void (*Apply)(Symbol *, int));
void         ShowSymbol(Symbol *, int);
Symbol      *ExistsSymbol(char *);
void	     FormatSymbol(char *, Symbol *);
void         FormatType(char *, MimeType);
void	     DecrNestLevel(void);
void	     IncrNestLevel(void);
int          CurrentNestLevel(void);
TreeNode    *CopyNode(TreeNode *);
void         TreeWalk(TreeNode *, void (*)(TreeNode *), void (*)(TreeNode *));
TreeNode    *MakeSiblings(TreeNode *, TreeNode *);
TreeNode    *MakeFamily(TreeNode *, TreeNode *);
TreeNode    *MakeConversionNode(ConvType);
TreeNode    *MakeOperatorNode(int);
TreeNode    *MakeIntegerNode(int);
TreeNode    *MakeFloatNode(float);
TreeNode    *MakeSymbolNode(Symbol *);
TreeNode    *MakeStringNode(char *);
TreeNode    *MakeCharNode(char);
void         TreePrint(TreeNode *, int);
void         LinkNodes(TreeNode *);
void         DummyVisit(TreeNode *);
void         SemanticRLvalueCheck(TreeNode *);
void         SemanticTypeCheck(TreeNode *);
void         SetBlankMimeType(MimeType);
void         RegisterSymbol(Symbol *);
void         CodeGen(TreeNode *, TreeNode *);
void         GenExprID(TreeNode *);
void         GenFuncExprID(TreeNode *);
void         SetStaticLinks(TreeNode *, TreeNode *);
void GenNoArgCode(int);
void GenOneArgCode(int, ArgType);
void GenTwoArgCode(int, ArgType, ArgType);
void GenFieldArgCode(int, char*, char*, char*);
void GenMethodArgCode(int, char*, char*, char*);
void GenClassArgCode(int, char*);
void GenLabelArgCode(int, char*);
void GenLocalVarArgCode(int, int);
void GenINVOKEINTERFACECode(int, char*, char*, char*, int);
void GenIINCCode(int, int, int);
void GenMULTIANEWARRAYCode(int, char*, int);
void GenNEWARRAYCode(int, int);
void GenLOOKUPSWITCHCode(int, char*, lookupentry*);
void GenTABLESWITCHCode(int, int, int, char*, tableentry*);
void InitAssembler();
void EndAssembler();
void SetThisClass(short, char*, char*);
void AddToInterfaceList(char*);
void SetSourceFile(char*);
void NewNewMethod(int);
void NewMethod(char*, char*, int, int);
void EndMethod();
void NewField(int, char*, char*, ArgType);
char* GetThisClass();
void DefineLabel(char*);
void NewLocalVar(char*, char*);
void IncrementLocalVarSlot(char*);
short GetLocalVar(char*);
lookupentry * AddToLookupList(lookupentry*, int, char*);
tableentry * AddToTableList(tableentry*, char*);
void AddToExceptionList(char*, char*, char*, char*);
void AddToThrowsList(char*);
void AddToLineNumberList(char*, short);
void AddToUserLocalVarList(char*, char*, char*, char*, short);