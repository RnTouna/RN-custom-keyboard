

import React, { Component } from 'react'
import PropTypes from 'prop-types'
import {
    NativeModules,
    TextInput,
    findNodeHandle,
    AppRegistry,
    Platform,DeviceEventEmitter
} from 'react-native'
import { EventEmitter } from 'events'

const { CustomKeyboard} = NativeModules


const {
    install, uninstall,
    insertText, backSpace, doDelete,
    moveLeft, moveRight,
    switchSystemKeyboard,
} = CustomKeyboard

export {
    install, uninstall,
    insertText, backSpace, doDelete,
    moveLeft, moveRight,
    switchSystemKeyboard,
};

const keyboardTypeRegistry = {}

let confirmOnClick = null

export function register(type, factory) {
  keyboardTypeRegistry[type] = factory
}

class CustomKeyboardContainer extends Component {
  render() {
    const {tag, type} = this.props
    const factory = keyboardTypeRegistry[type]
    if (!factory && __DEV__) {
      console.warn(`Custom keyboard type ${type} not registered.`)
      return null
    }
    const Comp = factory()
    return <Comp tag={tag} confirmOnClick={()=>{ if (confirmOnClick) confirmOnClick() }}/>
  }
}

AppRegistry.registerComponent("CustomKeyboard", ()=>CustomKeyboardContainer);

export class CustomTextInput extends Component {

  static propTypes = {
    ...TextInput.propTypes,
    customKeyboardType: PropTypes.string,
    // onFocus:PropTypes.func,
  };

  constructor(props) {
    super(props)
    if(Platform.OS === 'android'){
      this.listener = DeviceEventEmitter.addListener('CustomKeyboard_Resp', resp => {
        if(resp){
          if(this.props.onFocus)
            this.props.onFocus()
        }else{
          if(this.props.onBlur)
            this.props.onBlur()
        }
      });
    }
    confirmOnClick = this.props.confirmOnClick
  }

  hideCustomKeyboard() {
    try {
      if (Platform.OS === 'android') {
        switchSystemKeyboard(findNodeHandle(this.input))
      } else {
        // uninstall(findNodeHandle(this.input))
      }

    } catch (e) {
    }
  }

  showCustomKeyboard(){
    install(findNodeHandle(this.input), this.props.customKeyboardType)
  }

  componentWillUnmount(){
    this.listener && this.listener.remove()  //记得remove哦
    this.listener = null
  }

  componentDidMount() {
    install(findNodeHandle(this.input), this.props.customKeyboardType)
  }
  componentWillReceiveProps(newProps) {
    if (newProps.customKeyboardType !== this.props.customKeyboardType) {
      install(findNodeHandle(this.input), newProps.customKeyboardType)
    }
  }
  onRef = ref => {
    this.input = ref
  }
  render() {
    const { customKeyboardType, ...others } = this.props
    return <TextInput {...others} ref={this.onRef}/>
  }
}
