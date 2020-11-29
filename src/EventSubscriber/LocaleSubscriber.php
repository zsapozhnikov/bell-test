<?php


namespace App\EventSubscriber;


use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\RequestEvent;
use Symfony\Component\HttpKernel\KernelEvents;

class LocaleSubscriber implements EventSubscriberInterface
{
    private const HEADER_LANG = 'X-Lang';

    public static function getSubscribedEvents()
    {
        return [
            KernelEvents::REQUEST => [
                ['defineLocale', 8],
            ],
        ];
    }

    public function defineLocale(RequestEvent $event)
    {
        if (!$event->isMasterRequest()) {
            return;
        }
        $request = $event->getRequest();
        if ($request->headers->has(self::HEADER_LANG)) {
            $locale = $request->headers->get(self::HEADER_LANG);
            $request->setLocale($locale);
        } else {
            // TODO Доставать из параметров
            $request->setLocale('en');
        }
    }
}