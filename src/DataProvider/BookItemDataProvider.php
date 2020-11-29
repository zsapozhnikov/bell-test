<?php

namespace App\DataProvider;

use ApiPlatform\Core\DataProvider\ItemDataProviderInterface;
use ApiPlatform\Core\DataProvider\RestrictedDataProviderInterface;
use App\Entity\Book;
use Doctrine\ORM\EntityManagerInterface;
use Gedmo\Translatable\Entity\Translation;
use Symfony\Component\HttpFoundation\RequestStack;
use function Webmozart\Assert\Tests\StaticAnalysis\null;

final class BookItemDataProvider implements ItemDataProviderInterface, RestrictedDataProviderInterface
{
    private $em;
    private $requestStack;

    public function __construct(EntityManagerInterface $em, RequestStack $requestStack)
    {
        $this->em = $em;
        $this->requestStack = $requestStack;
    }

    public function supports(string $resourceClass, string $operationName = null, array $context = []): bool
    {
        return Book::class === $resourceClass;
    }

    public function getItem(string $resourceClass, $id, string $operationName = null, array $context = []): ?Book
    {
        $book = $this->em->getRepository(Book::class)->find($id);
        if ($book === null) {
            return null;
        }

        $translations = $this->em->getRepository(Translation::class)->findTranslations($book);
        $locale = $this->requestStack->getCurrentRequest()->getLocale();
        if (!isset($translations[$locale])) {
            return $book;
        }

        $book->setName($translations[$locale]['name']);

        return $book;
    }
}