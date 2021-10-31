const EOF = '@'

@enum StateName begin
  INIT
  PREKEY
  KEY
  PREVALUE
  VALUE
  KV_READ
  DONE
end

@enum DS begin
  PROPS
  CHILDREN
end

mutable struct State
  ix::Integer
  ch::Char
  name::StateName
  ds::DS
  props::Dict
  children::Vector

  State() = new(0, ' '::Char, INIT::StateName, PROPS::DS, (), [])
end

struct Parser
  input_str::String
  lim::Integer
  state::State
end

struct SgfTree
  properties::Dict
  chldren::Vector

  function SgfTree(props::Dict, children::Vector)
    # TODO: a bit of validation
    new(props, children)
  end
end

function parse(parser::Parser)::SgfTree
  ckey, cval, state_changed = ("", "", false)
  while true
    if parser.state.name == INIT::StateName
      init_state!(parser)
      parser.state.name == DONE::StateName && break
    end

    if parser.state.name == PREKEY::StateName
      next_char!(parser)
      parser.state.ch == EOF && return SgfTree(parser.state.props, parser.state.children)
    end

    ckey, state_changed = prekey_state!(parser, ckey, state_changed)

    if parser.state.ch == '['
      parser.state.name = VALUE::StateName
      next_char!(parser; raise_ex=true)
     else
       throw(ArgumentError("Unexpected character"))
    end

    cval = value_state!(parser, cval)
    @assert parser.state.name == KV_READ::StateName

    (ckey, cval) = update_tree(parser, ckey, cval)  ## we have a ckey/cval pair - record it and prep. for next value
    state_changed, ckey = dispatch(parser, ckey, state_changed)

    parser.state.name == DONE::StateName && break
  end

  @assert parser.state.name == DONE::StateName
  SgfTree(parser.state.props, parser.state.children)
end

function init_state!(state::State)
  # TODO
end

function prekey_state!(parser::Parser, ckey::String, state_changed::Bool)
  while parser.state.name == PREKEY::StateName
    if 'A' ≤ parser.state.ch ≤ 'Z'
      ckey = string(ckey, parser.state.ch)
      parser.state.name = KEY::StateName
    elseif parser.state.ch == ')' && parser.state.ix == parser.lim
      parser.state.name = DONE::StateName
    else
      throw(ArgumentError("Unexpected character - got $(parser.state.ch)"))
    end

    state_changed = true
  end
  (ckey, state_changed)
end

function key_state!(parser::Parser, ckey::String)
  while parser.state.name == KEY::StateName
    if 'A' ≤ parser.state.ch ≤ 'Z'
      ckey = string(ckey, parser.state.ch)
      next_char!(parser; raise_ex=true)
    elseif parser.state.ch == '['
      parser.state.name = PREVALUE::StateName
    else
      throw(ArgumentError("Unexpected character"))
    end
  end
  ckey
end

function value_state!(parser::Parser, cval)
  # TODO
end

function dispatch(parser::Parser, ckey::String, state_changed::Bool)
  # TODO
end

function update_tree(parser::Parser, cke::String, cval::String)
  # TODO
end

function next_char!(parser::Parser; raise_ex=false)
  ix = parser.state.ix += 1
  if ix < parser.lim
    parser.state.ch = parser.input_str[ix]
    return
  end

  parser.state.ch = EOF
  raise_ex && throw(ArgumentError("unexpected EOF"))
end
