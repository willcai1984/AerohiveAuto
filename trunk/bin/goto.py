import dis,pdb

#dummy functions serving as target of bytecode patching
def goto(label):
    pass

def label(label):
    pass

#
def decode_bytecode(fun):
    """Input: a function
       Ouput: a list of pairs (opcode, arguments)"""
    c = fun.func_code.co_code
    n = len(c)
    i = 0
    while i < n:
        op = c[i]
        i += 1
        arguments = ""
        if ord(op) >= dis.HAVE_ARGUMENT:
            arguments = c[i : i+2]
            i += 2
        yield (op, arguments)

def sample():
    goto(200)
    if 1 == 2:
        sample()
    else:
        print 'sample'
        
def test_decode(fun):
    for op,arg in decode_bytecode(fun):
        if arg=='':
            print dis.opname[ord(op)]
        else:
            print dis.opname[ord(op)] +' '+str(ord(arg[0]))+' '+str(ord(arg[1]))
        
def match_pattern(seq, i, p):
    """
    try to match pattern p to seq[i:], return None if match failed
    seq: output of decode_bytecode
    p -> [instr, instr, ...]
    instr -> (opcode, arg, arg)      opcode is a opcode string
    arg -> ''                        I don't give a damn about this arg
    arg -> integer                   match arg with number
    arg -> string                    the arg is key of the returned match dict from which the arg value can be extracted
    arg -> lambda                    lambda is evaluated with the argument, false return means failed match
    """
    #pdb.set_trace()
    m = {}

    for op, arg1, arg2 in p:
        if i==len(seq):
            return None
        
        if dis.opmap[op] != ord(seq[i][0]):
            return None

        if arg1 == '':
            pass
        else:
            if seq[i][1] == '': return None
            
            a1 = ord(seq[i][1][0])
            if type(arg1) is str:
                m[arg1]=a1
            elif type(arg1) is int:
                if arg1 != a1: return None
            elif not arg1(a1):
                return None

        #don't need arg2 in this program

        i+=1

        
    return m
        
def int_to_bytecode_arg(i):
    return chr(i  % 256) +\
           chr(i // 256)

def patch(fun):
    NOP = chr(dis.opmap['NOP'])
    co = fun.func_code
    old = list(decode_bytecode(fun))
    new = [] #a list of characters
    
    #mapping from label to bytecode offset
    label_table={}
    #if a goto(label) is seen but label is not seen
    #record for the number the bytecode offset of the
    #argument for JUMP_ABSOLUTE for later patching
    goto_table={}

    i=0
    #pdb.set_trace()
    while i<len(old):
        m= match_pattern(old, i,
                         [('LOAD_GLOBAL','fun_name',''),
                          ('LOAD_CONST','label',''),
                          ('CALL_FUNCTION',1,''),
                          ('POP_TOP','','')])
        if m:
            stmt = co.co_names[m['fun_name']]
            label = co.co_consts[m['label']]
            
        if   m and stmt == 'goto':
            # we have a goto statement
            if label_table.has_key(label):
                arg = int_to_bytecode_arg(label_table[label])
            else:
                arg = '\xff\xff'
                goto_table[label] =\
                 goto_table.get(label, [])+[len(new)+1]
            new += chr(dis.opmap['JUMP_ABSOLUTE'])
            new += arg
            #todo
            #this is to maintain proper bytecode offset to
            #source code line number mapping. A better way
            #would be fixing the mapping instead of using
            #placeholders
            new += NOP*7
            i += 4
        elif m and stmt == 'label':
            # we have a label statement
            label_table[label]=len(new)
            if goto_table.has_key(label):
                for offset in goto_table[label]:
                    new[offset: offset+2]=int_to_bytecode_arg(len(new))
                del goto_table[label]
            new += NOP*10
            i += 4
        else:
            # emit as-is 
            new += old[i][0] #the opcode
            new += old[i][1] #its args if it has 
            i += 1

    if len(goto_table):
        #todo: output line number
        raise Exception('missing label')

    import types
    newcode = types.CodeType(co.co_argcount,
                       co.co_nlocals,
                       co.co_stacksize,
                       co.co_flags,
                       ''.join(new),
                       co.co_consts,
                       co.co_names,
                       co.co_varnames,
                       co.co_filename,
                       co.co_name,
                       co.co_firstlineno,
                       co.co_lnotab)
    return types.FunctionType(newcode,fun.func_globals)
