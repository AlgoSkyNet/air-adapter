/**
 * Created by haseebriaz on 21/01/2015.
 */
package tests {
import fin.desktop.InterApplicationBus;

public class InterApplicationBusTest {

    private var bus: InterApplicationBus;

    public function InterApplicationBusTest() {

        bus = InterApplicationBus.getInstance();
      //  bus.send("interapp", "test", "Test EMssage");
        bus.addSubscribeListener(onSubscriberAdded);
        bus.addUnsubscribeListener(onSubscriberRemoved);
        bus.subscribe("interapp", "testmessages", onTestMessages, onSubsciptionSuccess);
    }

    private function onTestMessages(message: String, uuid: String): void{

        trace("TEST MESSAGE >> ", message);
    }

    private function onSubsciptionSuccess(): void{

        bus.subscribe("interapp", "subscriptiontest", onMessage);
        bus.subscribe("*", "broadcasttest", onMessage);
    }

    private function onSubscriberAdded(uuid: String, topic: String): void{

        trace("Subscriber added, application: ", uuid,", topic: ", topic, ";addSubscribeListener()");
        bus.send(uuid, topic, "test message to " + uuid);
        bus.publish("broadcasttest", "test message to all");
    }

    private function onSubscriberRemoved(uuid: String, topic: String): void{

        trace("Subscriber removed, application: ", uuid, "topic:", topic, ";addUnsubscribeListener()");
        bus.unsubscribe(uuid, topic, onMessage);
    }

    private function onMessage(message: String, uuid: String): void{

        trace("message recieved:", message, "from", uuid);
    }
}
}
