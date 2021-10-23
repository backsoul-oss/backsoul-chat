<template>
  <div class="flex justify-center items-center h-screen w-screen flex-col">
    <div>
      <ul
        class="flex justify-between relative z-10"
        v-for="item of messages"
        :key="item.id"
      >
        <li
          style="display: flex; justify-content: end; width: 100%"
          v-if="item.user_name == name"
        >
          <div class="container-message">
            <img
              src="https://i.pravatar.cc/300"
              alt=""
              srcset=""
              style="border-radius: 100%; width: 3rem;order: 2;"
            />
            <p>{{ item.message }}</p>
          </div>
        </li>
        <li v-if="item.user_name != name">
          <div class="container-message">
            <img
              src="https://i.pravatar.cc/300"
              alt=""
              srcset=""
              style="border-radius: 100%; width: 3rem"
            />
            <p>{{ item.user_name }}: {{ item.message }}</p>
          </div>
        </li>
      </ul>
      <div v-if="clientTyping">
        <div class="flex justify-start">
          <img
            src="~assets/img/typing.gif"
            alt=""
            srcset=""
            class="relative z-0"
            style="width: 5rem; margin-bottom: -2rem; margin-top: -1rem"
          />
        </div>
      </div>
      <input
        type="text"
        placeholder="ingresa tu mensaje"
        class="border-2 text-center relative z-10"
        v-model="message"
        @input="typingMessage"
      />
      <button
        class="bg-red-300 rounded-xl p-3 mt-3 text-white"
        @click="sendMsg"
      >
        Enviar mensaje
      </button>
    </div>

    <div>
      <h1>Personaliza tu nombre</h1>
      <input
        type="text"
        placeholder="ingresa tu nombre"
        class="border-2 text-center relative z-10"
        v-model="name"
      />
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      socket: null,
      message: '',
      messages: [],
      typing: false,
      clientTyping: false,
      user_id: null,
      name: Math.floor(Math.random() * 101),
    }
  },
  mounted() {
    this.socket = this.$nuxtSocket({
      channel: '/',
    })
    console.log(this.socket)
    this.socket.on('connected', (id) => {
      this.user_id = id
      console.log(this.user_id)
    })
    this.socket.on('msgToClient', (msg, cb) => {
      console.log(msg.user_name)
      console.log(this.name)
      if (msg.user_name != this.name && this.clientTyping == true) {
        this.clientTyping = false
      }
      this.messages.push(msg)
    })

    this.socket.on('sendTyping', (data, cb) => {
      console.log('un usuario esta escribiendo!!')
      console.log('el usuario que envio el mensaje: ', data.user_name)
      console.log('mi usuario: ', this.name)
      if (data.user_name != this.name) {
        this.clientTyping = true
      } else {
        this.clientTyping = false
      }
    })
  },
  methods: {
    sendMsg() {
      if (this.message != '') {
        this.socket.emit(
          'msgToServer',
          { user_name: this.name, message: this.message },
          (res) => {
            console.log(res)
          }
        )
        this.message = ''
      } else {
        alert('no puedes enviar un mensaje vacio')
      }
    },
    typingMessage(e) {
      this.socket.emit(
        'typingMessage',
        { user_name: this.name, message: e.target.value },
        (res) => {
          console.log(res)
        }
      )
    },
  },
}
</script>

<style>
.container-message {
  display: flex;
    align-items: center;
    gap: 1rem;
}
</style>
