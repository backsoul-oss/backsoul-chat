<template>
  <div class="flex justify-center items-center h-screen w-screen flex-col container-general">
    <div>
        <h1>Personaliza tu nombre</h1>
        <input
          type="text"
          placeholder="ingresa tu nombre"
          class="border-2 text-center relative z-10"
          v-model="name"
        />
      </div>
    <div
      class="flex justify-center items-center h-screen flex-col w-3/4 xl:w-2/3"
    >
      <div class="flex justify-center flex-col container-chat">
        <ul style="overflow: auto; padding: 1rem; border-radius: 1rem">
          <div
            v-for="item of messages"
            :key="item.id"
            class="flex justify-between relative z-10"
            style="margin: 1rem 0rem"
          >
            <li
              class="p-3 rounded-2xl"
              style="display: flex; justify-content: end; width: 100%;box-shadow: 1px 1px 8px -8px black;transition: 0.5s all;margin-bottom: 1rem;"
              v-if="item.user_name == name"
            >
              <div class="container-message">
                <img
                  src="https://i.pravatar.cc/300"
                  alt=""
                  srcset=""
                  style="border-radius: 100%; width: 3rem; order: 2"
                />
                <p>{{ item.message }}</p>
              </div>
            </li>
            <li class="p-3 rounded-2xl" v-if="item.user_name != name" style="width: 100%;box-shadow: 1px 1px 8px -8px black;transition: 0.5s all;margin-bottom: 1rem;">
              <div class="container-message">
                <img
                  src="https://i.pravatar.cc/300"
                  alt=""
                  srcset=""
                  style="border-radius: 100%; width: 3rem"
                />
                <p><strong>{{ item.user_name }}</strong>: {{ item.message }}</p>
              </div>
            </li>
          </div>
        </ul>
        <div class="flex justify-start" v-if="clientTyping">
          <img
            src="~assets/img/typing.gif"
            alt=""
            srcset=""
            class="relative z-0"
            style="width: 5rem; margin-bottom: -1rem; margin-top: -3rem"
          />
        </div>
      </div>
      <div
        class="flex justify-center items-center mt-3 rounded-xl w-full bg-white"
      >
        <input
          type="text"
          placeholder="ingresa tu mensaje"
          class="border-none text-center relative z-10 container-input"
          v-model="message"
          @input="typingMessage"
          v-on:keyup.enter="sendMsg"
        />
        <button class="rounded-xl p-3 text-white" @click="sendMsg" style="background: #40b9ff;">
          Enviar
        </button>
      </div>
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
.container-general{
  background: url('~/assets/img/bg.jpeg');
}
.container-chat {
  width: 100%;
  height: 50vh;
  box-shadow: 1px 2px 20px -16px black;
  border-radius: 1rem;
  overflow-y: auto;
      background: white;
  display: flex;
  justify-content: flex-end;
}
.container-input {
  border-radius: 1rem;
  width: 100%;
  height: 3rem;
  outline: none;
}
li:hover {
  transform: scale(1.02);
  box-shadow: 1px 1px 10px -8px black;
  transition: 0.5s all;
}
::-webkit-scrollbar {
  width: 15px;
  margin: 10px;
}

/* Track */
::-webkit-scrollbar-track {
  box-shadow: white;
  border-radius: 10px;
  padding: 1rem;
}

/* Handle */
::-webkit-scrollbar-thumb {
  background: rgb(0, 166, 255);
  border-radius: 10px;
}
</style>
